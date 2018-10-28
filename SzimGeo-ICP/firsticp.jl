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
The keywords scales the factor calculated inside this function.
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

"""
    randomSamplePoints(parray,prc)

Samples random elements from `pararray`. `pararray` must be an array of `Point3f0`.
The number of the sampled element is the `prc` percent of the input array's length.
As `prc` approaches 1, the performance gets poorer.
More info at the documentation of the `self_avoid_sample!` 
[function.](https://juliastats.github.io/StatsBase.jl/stable/sampling.html#StatsBase.self_avoid_sample!)
"""
function randomSamplePoints(parray,prc)
    @assert 0.01 <= prc && prc <=1
    if (eltype(parray) != Point3f0) && (eltype(parray) != SArray{Tuple{3},Float64,1,3})
        @error "The input array's element type must be Point3f0 or Float32 based SVector!"
    end
    numofsample = floor(size(parray,1)*prc)
    sampled_array = [@SVector zeros(3) for i in 1:numofsample]
    self_avoid_sample!(parray,sampled_array)
    return sampled_array
end

"""
    scaleMesh(sourceMesh, scale; MeshType = GLNormalMesh)

Scales a mesh with a scalar. Works only with a mesh that has only vertices.
"""
function scaleMesh(sourceMesh, scale; MeshType = GLNormalMesh)
    vts = vertices(sourceMesh)
    VertexType = vertextype(MeshType)
    target_vts  = vts.*scale
    FaceType = facetype(MeshType)
    fcs = FaceType[]
    return MeshType(target_vts, fcs)
end

"""
    createKnnPairArray(toPair_array, kdTree, kdd_array, sorted=true)

Pairs an array of points to their nearest point in the kdTree.
Returns an index array, which can be used to index the `kdd_array`,
and a matrix, which first column is the weight vector, and the second is
the corresponding distance (paired with the index array).
The last argument: `sorted` can be used to sort the results by the distance.
"""
function createKnnPairArray(toPair_array, kdTree, kdd_array, sorted=true)
    pid, pdx = knn(kdTree,toPair_array,1)
    p_nums = size(pid,1)
	pid_VA = VectorOfArray(pid)
    pdx_VA = VectorOfArray(pdx)
    pair_traits_Float = Array{Float32}(undef,p_nums,2)
    pair_traits_Int = convert(Array,pid_VA)'
    pair_traits_Float[:,1] = fill(1,p_nums)
    #pair_traits_Float[:,2] = [sqeuclidean(toPair_array[i],kdd_array[pair_traits_Int[i]]) for i in 1:p_nums] #Distances pkg
    pair_traits_Float[:,2] = convert(Array,pdx_VA)'
    if !sorted
        return pair_traits_Int,pair_traits_Float
    end    
    sorted_it = sortperm(pair_traits_Float[:,2])
    pair_traits_Float = pair_traits_Float[sorted_it,:]
    pair_traits_Int = pair_traits_Int[sorted_it]
    return pair_traits_Int, pair_traits_Float
end