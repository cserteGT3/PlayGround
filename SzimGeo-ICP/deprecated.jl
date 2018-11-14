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