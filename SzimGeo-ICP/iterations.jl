include("firsticp.jl")

"""
Easiest. Rejetc worst percent.
"""
function iterateEasyPeasy(aRef, aRed, kdRef, it, samp, rej)
    homTrDict = Dict{Int,Tuple}()
    # Calc the 0-th element of the dict for benchmark
    ri = randomSampleIndexes(samp,aRef,2)
    indM, trM = createKnnPairArray(aRed, ri, kdRef)
    #sort about distance and reject the worst
    refI, redI = rejectWorst(rej, indM, trM)
    refV = @view aRef[1:3,refI]
    redV = @view aRed[1:3,redI]
    errD = sum(colwise(SqEuclidean(),refV,redV))
    homTrDict[1] = (time_ns(),Matrix{eltype(aRef)}(I,4,4),errD)
    for i in 1:it
        ri = randomSampleIndexes(samp,aRef,2)
        indM, trM = createKnnPairArray(aRed, ri, kdRef)
        #sort about distance and reject the worst
        refI, redI = rejectWorst(rej, indM, trM)
        refV = @view aRef[1:3,refI]
        redV = @view aRed[1:3,redI]
        mu_ref = CoM(refV, 1)
        mu_red = CoM(redV, 1)
        Σ = crosscovMat(redV, refV, mu_red, mu_ref)
        rM = bestRotMat(Σ)
        bTr = mu_ref - rM*mu_red
        hM  = [rM bTr ; 0 0 0 1]
        aRed = hM*aRed
        redV = @view aRed[1:3,redI]
        errD = sum(colwise(SqEuclidean(),refV,redV))
        homTrDict[i+1] = (time_ns(),hM,errD)
    end
    return homTrDict
end

"""
Wrapper for the easiest.
"""
function wrapICP1(rfpc,redpc, ftype = Float32; itNum = 10, sampPC = 50, rejPC = 20)
    refA, redA, kd_ref = initICP(rfpc, redpc, ftype)
    retD = iterateEasyPeasy(refA, redA, kd_ref, itNum, sampPC, rejPC)
    return retD
end

"""
Second easiest. Rejection based on std.
"""
function iterateSigmaRej(aRef, aRed, kdRef, it, samp)
    homTrDict = Dict{Int,Tuple}()
    # Calc the 0-th element of the dict for benchmark
    ri = randomSampleIndexes(samp,aRef,2)
    indM, trM = createKnnPairArray(aRed, ri, kdRef)
    #rejection with the std
    refI, redI = reject25Sigma(indM, trM)
    refV = @view aRef[1:3,refI]
    redV = @view aRed[1:3,redI]
    errD = sum(colwise(SqEuclidean(),refV,redV))
    homTrDict[1] = (time_ns(),Matrix{eltype(aRef)}(I,4,4),errD)
    for i in 1:it
        ri = randomSampleIndexes(samp,aRef,2)
        indM, trM = createKnnPairArray(aRed, ri, kdRef)
        #sort about distance and reject the worst
        refI, redI = reject25Sigma(indM, trM)
        refV = @view aRef[1:3,refI]
        redV = @view aRed[1:3,redI]
        mu_ref = CoM(refV, 1)
        mu_red = CoM(redV, 1)
        Σ = crosscovMat(redV, refV, mu_red, mu_ref)
        rM = bestRotMat(Σ)
        bTr = mu_ref - rM*mu_red
        hM  = [rM bTr ; 0 0 0 1]
        aRed = hM*aRed
        redV = @view aRed[1:3,redI]
        errD = sum(colwise(SqEuclidean(),refV,redV))
        homTrDict[i+1] = (time_ns(),hM,errD)
    end
    return homTrDict
end


"""
Wrapper for the rejection based iteration.
"""
function wrapICP3(rfpc,redpc, ftype = Float32; itNum = 10, sampPC = 50)
    refA, redA, kd_ref = initICP(rfpc, redpc, ftype)
    retD = iterateSigmaRej(refA, redA, kd_ref, itNum, sampPC)
    return retD
end