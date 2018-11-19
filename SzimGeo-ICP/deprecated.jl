"""
    convert2HomogeneousArray(toHArray, fltype = Float32)
	
Convert an array of points to an array of homogeneous vectors.

Representation of the homogeneous vectors are `SVector{4,fltype}`.
"""
function convert2HomogeneousArray(toHArray, fltype = Float32)
    hom_arr = [ SVector{4,fltype}(vcat(toHArray[i]...,1)) for i in 1:size(toHArray,1) ]
    return hom_arr
end

#create GUI to update the bunny's position
#=
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
=#
#trGui = vbox(slix,sliy,sliz);

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
    makeMatrixFromMesh(toMatrix, fltype = Float32)

Convert an array of points to matrix, with size n×3.
"""
function makeMatrixFromMesh(toMatrix, fltype = Float32)
    hom_arr = ones(fltype,size(toMatrix,1),3)
    vaoa = VectorOfArray(toMatrix)
    hom_arr[:,1:3] = convert(Array,vaoa)'
    return hom_arr
end

"""
    sortIndandTraits(indexMat, traitMat; sortby = 2)

Sort index and trait matrix by the distances in the trait matrix.

Return the sorted index and trait matrix, and also the permutation array.

# Arguments
- `sortby = 2`: selects the trait matrix's column to sort by.

# Examples

This example shows how to acces the the trait matrix's elements.
`indM` is an indexer matrix and the second column of `traitM`
contains the distances to sort by.
`indM` contains the indexes that pairs `ref_array` and `read_array`.
`euclidean()` is a function from `Distances` package.

```julia-repl
julia> s_indM, s_traitM, s_it = sortIndandTraits(indM, traitM);
julia> inds = 1:10;
julia> dist1 = euclidean.(ref_array[s_indM[inds,1]],read_array[s_indM[inds,2]]);
julia> dist2 = s_traitM[inds,2];
julia> ds_ind = sortperm(s_it);
julia> dist3 = s_traitM[ds_ind[s_indM[inds,2]],2];
julia> dist4 = traitM[s_indM[inds,2],2];
julia> dist1 == dist2 == dist3 == dist4
true
```
"""
function sortIndandTraits(indexMat, traitMat; sortby = 2)
	sorted_i, s_it = sortIndexes(indexMat, traitMat[:,sortby])
    sorted_tr = traitMat[s_it,:]
    return sorted_i, sorted_tr, s_it
end

# Again new

#input: reading és reference
#homogén koordináták: oszlopvektorok egymás mellé helyezve
reference_pc = deepcopy(half_b_sc);
reading_pc = noisifyMesh(half_b_rot_sc);
#refA, redA, kd_ref, kd_red = initICP(reference_pc, reading_pc);

#here starts the iteration
pairPC = 30; #using the pairPC percent of the pairs
rmPC = 20; #remove the rmPC % worst pairs
ri = randomSampleIndexes(pairPC,refA,2); #random indexes
indM, traitM = createKnnPairArray(redA[:,ri], kdtree_ref); #pairing the points, here @view can't be used
#different rejection methods come here
    distA = @view traitM[:,2];
    sindM, sit = sortIndexes(indM, distA);
    #reject the % worst
    chind, chit = chopEndOfArray(rmPC, sindM, sit);
    refV = @view refA[1:3,chind[1:end,1]];
    redV = @view redA[1:3,chind[1:end,2]];
#refV and redV contains the paired and filtered points
mu_ref = CoM(refV, 1);
mu_red = CoM(redV, 1);
# cross-cov. mat.
sigma = crosscovMat(redV, refV, mu_red, mu_ref);
# the best rotation matrix
rMat = bestRotMat(sigma);
# best translation vector
bTr = mu_ref - rMat*mu_red;
homTR  = [rMat bTr ; 0 0 0 1]

#p is the reading, x is the reference
#the inverse of the returned matrix should be used
function useAll(p, x)
    mu_p = CoM(p,1)
    mu_x = CoM(x,1)
    Sigma = crosscovMat(p, x, mu_p, mu_x)
    rM = bestRotMat(Sigma)
    bTr = mu_x - rM*mu_p
    return [rM bTr; 0 0 0 1]
end


# dummy test
hMat = useAll(refA[1:3,:],redA[1:3,:])
r2Arr =  inv(hMat) * redA
rtMi = makeMeshfromMatrix(r2Arr[1:3,:])
placeMeshInLife(vis, rtMi, "inversed", "orange")