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

Convert matrix (with size: 3×n) to mesh.

Only vertices can be set.
"""
function makeMeshfromMatrix(vtarray, MeshType = GLNormalMesh)
    vl = size(vtarray, 2)
    VertexType = vertextype(MeshType)
    FaceType = facetype(MeshType)
    vts = Array{VertexType}(undef, vl)
    fcs = FaceType[]
    for i in 1:vl
        vts[i] = convert(Point3f0, vtarray[1:3,i])
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
        #@info "The white noise scaling factor is $wfactor"
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
    createKnnPairArray(toPair, indexes, kdTree; fltype = Float32)

Pair an array of points to their nearest point in the kdTree.

Return values are two matrixes, the first contains
the indexes of the kd treed array and the `indexes` indexer array.
Second matrix contains a weight vector, and an array containing the distances.

# Examples

This example shows how to access the paired elements.
Using with a reference array `ref_array`, and a sampled `read_array`.
`euclidean()` is a function from `Distances` package.

```julia-repl
julia> kdtree_ref = KDTree(ref_array);
julia> indexM, traitM = createKnnPairArray(read_array, kdtree_ref);
julia> inds = 1;
julia> dist1 = euclidean(ref_array[:,indexM[inds,1]],read_array[:,indexM[inds,2]]);
julia> dist2 = traitM[inds,2];
julia> dist1 == dist2
true
```
"""
function createKnnPairArray(toPair, indexes, kdTree; fltype = Float32)
    pid, pdx = knn(kdTree,toPair[:,indexes],1, false)
    p_nums = size(pid,1)
	pid_VA = VectorOfArray(pid)
    pdx_VA = VectorOfArray(pdx)
    pair_traits_Float = Array{fltype}(undef,p_nums,2)
    indexer_Int = Array{Int}(undef,p_nums,2)
    indexer_Int[:,1] = convert(Array,pid_VA)'
    indexer_Int[:,2] = indexes
    pair_traits_Float[:,1] = fill(1,p_nums)
    pair_traits_Float[:,2] = convert(Array,pdx_VA)'
    return indexer_Int, pair_traits_Float
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
    chopEndOfArray(prc, array)

Chop `prc`% of the end of array or matrix.
"""
function chopEndOfArray(prc, array::AbstractArray{T,1}) where T<:Number
    @assert 0 <= prc && prc < 100 "The percent should be: 0 <= prc < 100."
    issi = size(array,1)
    numofsample = issi-floor(Int,issi*prc/100)
    return @view array[1:numofsample]
end

function chopEndOfArray(prc, array::AbstractArray{T,2}) where T<:Number
    @assert 0 <= prc && prc < 100 "The percent should be: 0 <= prc < 100."
    issi = size(array,1)
    numofsample = issi-floor(Int,issi*prc/100)
    return @view array[1:numofsample,:]
end

"""
    chopEndOfArray(prc, tupi...)

Can be applied to any number of arrays, matrixes.
"""
function chopEndOfArray(prc, tupi...)
    @assert 0 <= prc && prc < 100 "The percent should be: 0 <= prc < 100."
    ret = ()
    for i in 1:length(tupi)
		ret = (ret...,chopEndOfArray(prc,tupi[i]))
    end
    return ret
end

"""
    sortIndexes(indM, dist_array)

Sort index matrix by a distance array.

Return the sorted matrix and the permutation array.
"""
function sortIndexes(indM, dist_array)
    s_it = sortperm(dist_array)
    sorted_i = indM[s_it,:]
    return sorted_i, s_it
end

"""
    convert2HomCoordMatrix(v, fltype = Float32)

Convert an array of points to matrix of homogeneous points.

Return a matrix, that contains column vectors concatenated horizontally.
"""
function convert2HomCoordMatrix(v, fltype = Float32)
    hom_arr = ones(fltype,4,size(v,1))
    vaoa = VectorOfArray(v)
    hom_arr[1:3,:] = convert(Array,vaoa)
    return hom_arr
end

"""
    randomSampleIndexes(percent, l::Number)

Sample `percent`% random indexes, where `l` can be the largest index.
"""
function randomSampleIndexes(percent, l::Number)
    @assert 1 <= percent && percent <= 100 "The percent should be: 1 <= prc <= 100."
    numofsample = floor(Int,l*percent/100)
    @assert numofsample > 0 "$numofsample index is choosed. Edit the percent!"
    sampled_array = Array{Int}(undef,numofsample)
    self_avoid_sample!(1:l,sampled_array)
    return sampled_array
end

"""
    randomSampleIndexes(percent, array, dim)

Can be applied to arrays, where `dim` sepcifies the dimension along the largest index counted.

Falls back to `randomSampleIndexes(percent, l::Number)`.
"""
function randomSampleIndexes(percent, array, dim)
    @assert dim <= ndims(array) "dim is larger than the array's dimensions. This doesn't makes sense at all..."
    return randomSampleIndexes(percent, size(array,dim))
end

"""
    giveTranspose(A)

Wrapper for `transpose()`.
"""
function giveTranspose(A)
    return transpose!(Array{eltype(A)}(undef, size(A, 2), size(A, 1)), A)
end

"""
    CoM(arr, vdim)

Compute the center of mass.

`dim` tells, in which direction is one vector in the matrix.
"""
function CoM(arr, vdim)
    @assert ndims(arr) == 2 "This function can only handle matrixes."
    com_size = size(arr,vdim)
    l_dir = vdim == 1 ? 2 : 1
    mu = similar(arr,com_size)
    if l_dir == 1
        for i in 1:com_size
            p = @view arr[:,i]
            mu[i] = sum(p)
        end
    elseif l_dir == 2
         for i in 1:com_size
            p = @view arr[i,:]
            mu[i] = sum(p)
        end
    end
    return mu/size(arr,l_dir)
end

"""
    crosscovMat(readvec, refvec)

Compute the cross-covariance matrix.
"""
function crosscovMat(readvec, refvec)
    @assert size(readvec) == size(refvec) "Arrays should have the same size."
    l = size(refvec,2)
    sigm = readvec*refvec'
    sigm = sigm/l - CoM(readvec,1)*CoM(refvec,1)'
    return sigm
end

"""
    crosscovMat(readvec, refvec, mu_read, mu_ref)

Center of mass vectors can be provided.
"""
function crosscovMat(readvec, refvec, mu_read, mu_ref)
    @assert size(readvec) == size(refvec) "Arrays should have the same size."
    l = size(refvec,2)
    sigm = readvec*refvec'
    sigm = sigm/l - mu_read*mu_ref'
    return sigm
end

"""
    bestRotMat(sigma)

Compute the best rotation matrix, based on the cross-covariance matrix.
"""
function bestRotMat(sigma)
    deltaV(m) = [m[2,3]-m[3,2], m[3,1]-m[1,3], m[1,2]-m[2,1]]
    Δ = deltaV(sigma)
    Qmat = vcat(hcat(tr(sigma),Δ'),hcat(Δ,sigma+sigma'-tr(sigma)*Matrix{eltype(sigma)}(I,3,3)))
    qr = eigen(Qmat).vectors[:,end]
    R = [qr[1]^2+qr[2]^2-qr[3]^2-qr[4]^2 2(qr[2]*qr[3]-qr[1]*qr[4]) 2(qr[2]*qr[4]+qr[1]*qr[3])
     2(qr[2]*qr[3]+qr[1]*qr[4]) qr[1]^2+qr[3]^2-qr[2]^2-qr[4]^2 2(qr[3]*qr[4]-qr[1]*qr[2])
     2(qr[2]*qr[4]-qr[1]*qr[3]) 2(qr[3]*qr[4]+qr[1]*qr[2]) qr[1]^2+qr[4]^2-qr[2]^2-qr[3]^2]
    return R
end

"""
    initICP(mesh1, mesh2, ftyp = Float32)

Make initial arrays and kd tree for ICP.

Return the vertices of the two mesh (in a homogeneous coordinate matrix)
and the kd tree of the first mesh.
"""
function initICP(mesh1, mesh2, ftyp = Float32)
    a1 = convert2HomCoordMatrix(vertices(mesh1), ftyp)
    a2 = convert2HomCoordMatrix(vertices(mesh2), ftyp)
    k1 = KDTree(a1)
    return a1, a2, k1
end

"""
    resettransform!(wat)


Reset the transformation of the given object!
"""
resettransform!(wat) = settransform!(wat,AffineMap([1 0 0;0 1 0;0 0 1],[0,0,0]))

"""
    rejectWorst(pc, iM, tM, fAv, dAv)

Reject the worst `pc` percent of the pairs.

Return with `SubArrays`.

# Arguments
- `iM`: index matrix (result of `createKnnPairArray()`).
- `tM`: trait matrix (result of `createKnnPairArray()`).
- `fAv`, `dAv`: referenc and reading arrays.
"""
function rejectWorst(pc, iM, tM, fAv, dAv)
    dA =  @view tM[:,2]
    siM, sind = sortIndexes(iM, dA)
    chI, chit = chopEndOfArray(pc, siM, sind)
    fVv = @view fAv[1:3,chI[:,1]]
    dVv = @view dAv[1:3,chI[:,2]]
    return fVv, dVv
end


"""
    rejectWorst(pc, iM, tM)

Can generate the indexers only.

"""
function rejectWorst(pc, iM, tM)
    dA =  @view tM[:,2]
    siM, sind = sortIndexes(iM, dA)
    chI, chit = chopEndOfArray(pc, siM, sind)
    reffI = @view chI[:,1]
    readdI = @view chI[:,2]
    return reffI, readdI
end

"""
    postProcDict(d) -> (iterA, timeA, hmD, errA)

Process the returned dictionary.

Yields two time array in usec and msec (first is the length of every iteration,
second is the absolute time), a dictionary of transformation matrixes
and the error array.
"""
function postProcDict(d)
    l = length(d)
    @assert l > 0 "Why would you do that to an empty dictionary?"
    #bemenet: (time_ns(),hM,errD)
    #kimenet: time μs tömbben, hm-ek egy dict-ben, err egy tömbben
    tN = 1
    hmN = 2
    erN = 3
    t_arr = zeros(l-1)
	t2 = zeros(l)
    erA = Array{typeof(d[1][erN])}(undef,l)
    mD = Dict{Int,typeof(d[1][hmN])}()
    for i in 1:l-1
        intD = d[i+1][tN] - d[i][tN]
        t_arr[i] = intD/1000 # nanosec -> microsec
		t2[i+1] = (d[i+1][tN]- d[1][tN])/1000000
        mD[i] = d[i][hmN]
        erA[i] = d[i][erN]
    end
    mD[l] = d[l][hmN]
    erA[l] = d[l][erN]
    return t_arr, t2, mD, erA
end

"""
    sumcumHM(d)

Accumulate the homogeneous transformation matrix into one matrix.
"""
function sumcumHM(d)
    @assert length(d) > 0 "Why would you do that to an empty dictionary?"
    ret = d[1]
    for i in 2:length(d)
        ret = d[i] * ret
    end
    return ret
end

"""
    reject25Sigma(iM, tM) -> (refI, redI)

Reject the pairs, that are out of the mean+-2.5σ range.

Return with the view of the index matrix.
"""
function reject25Sigma(iM, tM)
    dA = @view tM[:,2]
    mA, stdA = mean_and_std(dA)
    mixx = mA-2.5*stdA
    maxx = mA+2.5*stdA
    bI = [mixx <= val <= maxx ? true : false for (_,val) in enumerate(dA)]
    rejiRef = @view iM[bI,1]
    rejiRed = @view iM[bI,2]
    return rejiRef, rejiRed
end

"""
    transformMesh(mesh, trM)

Transform the mesh with the given homogeneous matrix.

Returns a new object.
"""
function transformMesh(mesh, trM)
    vs = convert2HomCoordMatrix(vertices(mesh))
    vn = trM * vs
    return makeMeshfromMatrix(vn)
end