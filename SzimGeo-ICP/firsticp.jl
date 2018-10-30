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

Convert array (containing arrays that have 3 elements) to mesh.

Only vertices can be set.
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

Convert matrix (with size: n×3) to mesh.

Only vertices can be set.
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
    placeMeshInLife(space, mesh, idstring, cstring = "black")

Place mesh in a `MeshCat` visualizer.

Grouping is not supported.
`cstring` maps to the `Color` package's dictionary.
"""
function placeMeshInLife(space, mesh, idstring, cstring = "black")
    vtrs = vertices(mesh)
    setobject!(space[idstring],PointCloud(vtrs,fill(convert(RGB{Float32},(parse(Colorant,cstring))),length(vtrs))))
end

"""
    noisifyMesh(sMesh, noisetype = :white; MeshType = GLNormalMesh, wfactor = 1, ofactor = 1)

Place random noise to the mesh.	

# Arguments
- `noistype`: can be: `:white`, `:outlier`, or `:both`
- `wfactor`: scaling value for white noise (scales the factor calculated by the function).
- `ofactor`: scaling value for outlier noise (scales the factor calculated by the function).
"""
function noisifyMesh(sMesh, noisetype = :white; MeshType = GLNormalMesh, wfactor = 1, ofactor = 1)
    vts = vertices(sMesh)
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
    randomSamplePoints(parray, prc)

Sample random elements from an array.

As `prc` approaches 100%, the performance gets poorer.
More info at the documentation of the `self_avoid_sample!` 
[function.](https://juliastats.github.io/StatsBase.jl/stable/sampling.html#StatsBase.self_avoid_sample!)

# Arguments
- `parray`: array of dim4 `SVector`
- `prc`: percentage of sampled points 
"""
function randomSamplePoints(parray, prc)
    @assert 1 <= prc && prc <= 100 "The percent should be: 1 <= prc <= 100."
    numofsample = floor(Int,size(parray,1)*prc/100)
    sampled_array = [SVector{4,eltype(parray[1])}(zeros(4)) for i in 1:numofsample]
    self_avoid_sample!(parray,sampled_array)
    return sampled_array
end

"""
    scaleMesh(sourceMesh, scale; MeshType = GLNormalMesh)

Scale mesh with a scalar. 

Only vertices are scaled, doesn't return faces.
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
    createKnnPairArray(toPair, kdTree; fltype = Float32)

Pair an array of points to their nearest point in the kdTree.

Return values are two matrices, the first contains the indexes of the kd treed array,
and the indexes of the `toPair` array.
Second matrice contains a weight vector, and an array containing the distances.
"""
function createKnnPairArray(toPair, kdTree; fltype = Float32)
    pid, pdx = knn(kdTree,toPair,1)
    p_nums = size(pid,1)
	pid_VA = VectorOfArray(pid)
    pdx_VA = VectorOfArray(pdx)
    pair_traits_Float = Array{fltype}(undef,p_nums,2)
    indexer_Int = Array{Int}(undef,p_nums,2)
    indexer_Int[:,1] = convert(Array,pid_VA)'
    indexer_Int[:,2] = collect(1:p_nums)
    pair_traits_Float[:,1] = fill(1,p_nums)
    pair_traits_Float[:,2] = convert(Array,pdx_VA)'
    return indexer_Int, pair_traits_Float
end

"""
    convert2HomogeneousArray(toHArray, fltype = Float32)
	
Convert an array of points to an array of homogeneous vectors.

Representation of the homogeneous vectors are `SVector{4,fltype}`.
"""
function convert2HomogeneousArray(toHArray, fltype = Float32)
    hom_arr = [ SVector{4,fltype}(vcat(toHArray[i]...,1)) for i in 1:size(toHArray,1) ]
    return hom_arr
end

"""
    allEqual(x)

Return `true`, if the array contains the same elements.
"""
@inline function allEqual(x)
    length(x) < 2 && return true
    e1 = x[1]
    @inbounds for i=2:length(x)
        x[i] == e1 || return false
    end
    return true
end

"""
    chopEndOfArray(prc, tupi...)

Chop `prc`% of the end of the array.

If multiple arrays are given, all their sizes must be the same.
"""
function chopEndOfArray(prc, tupi...)
    @assert allEqual([size(tupi[i],1) for i in 1:length(tupi)]) "The arrays should have the same length."
    @assert allEqual([size(tupi[i],2) for i in 1:length(tupi)]) "The matrices should have the same width."
    @assert 1 <= prc && prc < 100 "The percent should be: 1 <= prc < 100."
    issi = size(tupi[1],1)
    numofsample = issi-floor(Int,issi*prc/100)
    ret = ()
    if size(tupi[1],2) > 1
        for i in 1:length(tupi)
            ret = (ret...,tupi[i][1:numofsample,:])
        end
    else
        for i in 1:length(tupi)
            ret = (ret...,tupi[i][1:numofsample])
        end
    end
    return ret
end

function chopEndOfArray(prc, tupi)
    issi = size(tupi,1)
    @assert 1 <= prc && prc < 100 "The percent should be: 1 <= prc < 100."
    numofsample = issi-floor(Int,issi*prc/100)
    if size(tupi,2) > 1
        return tupi[1:numofsample,:]
    else
        return tupi[1:numofsample]
    end
end