include("firsticp.jl")

"""
Easiest. Reject worst percent.
"""
function iterateEasyPeasy(aRef, aRed, kdRef, itmax, samp, rej, errmax)
    homTrDict = Dict{Int,Tuple}()
    # Calc the 0-th element of the dict for benchmark
    maxsamp = min(size(aRef,2),size(aRed,2))
	ri = randomSampleIndexes(samp,maxsamp)
    indM, trM = createKnnPairArray(aRed, ri, kdRef)
    refV = @view aRef[1:3,indM[:,1]]
    redV = @view aRed[1:3,indM[:,2]]
    errD = sum(colwise(SqEuclidean(),refV,redV))
    homTrDict[1] = (time_ns(),Matrix{eltype(aRef)}(I,4,4),errD)
    for i in 1:itmax
        ri = randomSampleIndexes(samp,maxsamp)
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
		if errD < errmax
			@info "Finished with error: $errD, at threshold: $errmax, at the $i iteration"
			break
		end
    end
    return homTrDict
end

"""
    wrapICP1(rfpc,redpc, ftype = Float32; itMax= 1000, sampPC = 10, rejPC = 20, errMax = 0.5)

Wrapper for the easiest.
"""
function wrapICP1(rfpc,redpc, ftype = Float32; itMax= 1000, sampPC = 10, rejPC = 20, errMax = 0.5)
    refA, redA, kd_ref = initICP(rfpc, redpc, ftype)
    retD = iterateEasyPeasy(refA, redA, kd_ref, itMax, sampPC, rejPC, errMax)
    return retD
end

"""
Second easiest. Rejection based on std.
"""
function iterateSigmaRej(aRef, aRed, kdRef, itmax, samp, errmax)
    homTrDict = Dict{Int,Tuple}()
    # Calc the 0-th element of the dict for benchmark
	maxsamp = min(size(aRef,2),size(aRed,2))
    ri = randomSampleIndexes(samp,maxsamp)
    indM, trM = createKnnPairArray(aRed, ri, kdRef)
    refV = @view aRef[1:3,indM[:,1]]
    redV = @view aRed[1:3,indM[:,2]]
    errD = sum(colwise(SqEuclidean(),refV,redV))
    homTrDict[1] = (time_ns(),Matrix{eltype(aRef)}(I,4,4),errD)
    for i in 1:itmax
        ri = randomSampleIndexes(samp,maxsamp)
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
        errD = sum(colwise(SqEuclidean(),refV,redV))/size(refV,2)
        homTrDict[i+1] = (time_ns(),hM,errD)
		if errD < errmax
			break
		end
    end
	@info "Finished with error: $(homTrDict[length(homTrDict)][3]), at threshold: $errmax, at the $(length(homTrDict)-1)th iteration"
    return homTrDict
end


"""
    wrapICP3(rfpc,redpc, ftype = Float32; itMax = 1000, sampPC = 10, errMax = 0.0001)

Wrapper for the rejection based iteration.
"""
function wrapICP3(rfpc,redpc, ftype = Float32; itMax = 1000, sampPC = 10, errMax = 0.0001)
    refA, redA, kd_ref = initICP(rfpc, redpc, ftype)
    retD = iterateSigmaRej(refA, redA, kd_ref, itMax, sampPC, errMax)
    return retD
end