#Curve endpoint type
struct CurveEP
    pA
    pB
    tA
    tB
    function CurveEP(p1,p2,t1,t2)
        if !(size(p1)==size(p2)==size(t1)==size(t2))
            error("Vectors does not have the same dimensions.")
        end
        if length(p1)>3 && length(p1)<2
            error("Dimensions below 2 and over 3 can not be used.")
        end
        if size(p1)[1]==1
            p11=vec(p1)
            p22=vec(p2)
            t11=vec(t1)
            t22=vec(t2)
            new(p11,p22,t11,t22)
            println("Arguments were reshaped to vector.")
        else
            new(p1,p2,t1,t2)
        end
    end
end
Base.show(io::IO,c::CurveEP) = print(io,"Curve endpoint:\npA=$(c.pA)\tpB=$(c.pB)\ntA=$(c.tA)\ttB=$(c.tB)")

#Hermite interpolation
F0(t)=2*t^3-3*t^2+1
G0(t)=t^3-2*t^2+t
F1(t)=-2*t^3+3*t^2
G1(t)=t^3-t^2

function HermitInterpolate(es,x)
    if x>=0 && x<=1
        return es.pA*F0(x)+es.tA*G0(x)+es.pB*F1(x)+es.tB*G1(x)
    else
        error("Hermit interpolation is only valid in the range of [0,1]")
    end
end

function HermitInterpolate(epoint,x::Array)
    retx=zeros(Float64,size(x,1))
    rety=zeros(Float64,size(x,1))
    for (i,curr) in enumerate(x)
        temp=HermitInterpolate(epoint,curr)
        retx[i]=temp[1]
        rety[i]=temp[2]
    end
    return retx,rety
end
