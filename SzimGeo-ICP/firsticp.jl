#create GUI to update the bunny's position
bunnyVec = MVector(0.0,0.0,0.0);

function updBT(key,val)
    if key == :x
        global bunnyVec[1] = val
    elseif key == :y
        global bunnyVec[2] = val
    elseif key == :z
        global bunnyVec[3] = val
    end
    settransform!(vis[:fbunny],Translation(bunnyVec))
end

sliderRange = -5:0.01:5;

slix = slider(sliderRange,label="x axis",value=0);
sliy = slider(sliderRange,label="y axis",value=0);
sliz = slider(sliderRange,label="z axis",value=0);

on(n -> updBT(:x,n),slix);
on(n -> updBT(:y,n),sliy);
on(n -> updBT(:z,n),sliz);

#trGui = vbox(slix,sliy,sliz);

#Real ICP things

"""
    makeMeshfromArray(vtarray, MeshType = GLNormalMesh)

Converts an array (containing arrays that have 3 elements) to mesh.
With this function, only the vertices can be set.
"""
function makeMeshfromArray(vtarray, MeshType = GLNormalMesh)
    vl = size(vtarray, 1)
    VertexType = vertextype(MeshType)
    FaceType = facetype(MeshType)
    vts = Array{VertexType}(undef, vl)
    fcs = FaceType[]
    for i in 1:vl
        vts[i] = convert(Point3f0, vtarray[i])
    end
    return MeshType(vts, fcs)
end


"""
    makeMeshfromMatrix(vtarray, MeshType = GLNormalMesh)

Converts a matrix (with size: n×3) to mesh.
With this function, only the vertices can be set.
"""
function makeMeshfromMatrix(vtarray, MeshType = GLNormalMesh)
    vl = size(vtarray, 1)
    VertexType = vertextype(MeshType)
    FaceType = facetype(MeshType)
    vts = Array{VertexType}(undef, vl)
    fcs = FaceType[]
    for i in 1:vl
        vts[i] = convert(Point3f0, vtarray[i,:])
    end
    return MeshType(vts, fcs)
end

"""
    placeMeshInLife(space,meshe,idstring,cstring="black")

Places the given mesh in the given `MeshCat` visualizer. An `idstring` must be given,
to identify the mesh. Grouping is not supported.
The color of the mesh can be set with a string, which maps to the `Color` package's dictionary.
If no `cstring` is given, the default black will be used.
"""
function placeMeshInLife(space,meshe,idstring,cstring="black")
    vtrs = vertices(meshe)
    setobject!(space[idstring],PointCloud(vtrs,fill(convert(RGB{Float32},(parse(Colorant,cstring))),length(vtrs))))
end

"""
    noisifyMesh(sourceMesh, noisetype = :white; MeshType = GLNormalMesh, wfactor = 1, ofactor = 1)
	
Places random noise to the given mesh (returns with a new object).
The type of the noise can be choosed: `:white`, which is random noise,
`:outlier`, which adds outliers to the mesh and `:both`. Scaling can be fine tuned
with the `wfactor` and the `ofcator` keywords (for white and outlier noise respectively).
The keywords scale the factor calculated by this function.
"""
function noisifyMesh(sourceMesh, noisetype = :white; MeshType = GLNormalMesh, wfactor = 1, ofactor = 1)
    vts = vertices(sourceMesh)
    vl = size(vts, 1)
    VertexType = vertextype(MeshType)
    target_vts = Array{VertexType}(undef, vl) 
    if noisetype == :white
        minv = minimum(norm.(vts))
        #Scaling the random numbers with the tenth of the smallest vector
        wfactor *= minv * 0.05
        @info "The white noise scaling factor is $wfactor"
        rand_arr = randn(Float32,(vl,3)).*wfactor 
    end
    for (ind,val) in enumerate(vts)
        if noisetype == :white
            target_vts[ind] = val + Point3f0(rand_arr[ind,:])
        end
    end
    FaceType = facetype(MeshType)
    fcs = FaceType[]
    return MeshType(target_vts, fcs)
end