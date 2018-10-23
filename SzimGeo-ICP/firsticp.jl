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
    placeMeshInLife(space,idstring,meshe,cstring)

Places the given mesh in the given MeshCat visualizer. An idstring must be given,
to identify the mesh. Currently grouping is not supported.
The color of the mesh can be set with a string, which maps to the Color package's dictionary.
"""
function placeMeshInLife(space,idstring,meshe,cstring)
    vtrs = vertices(meshe)
    setobject!(space[idstring],PointCloud(vtrs,fill(convert(RGB{Float32},(parse(Colorant,cstring))),length(vtrs))))
end