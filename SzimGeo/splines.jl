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
        if abs(1-norm(t1)) > eps() || abs(1-norm(t2)) > eps()
            error("Tangents are not normed.")
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

#=
function CurveEP(p1,p2,t1,t2;norm=false)
    if norm
        t11=normalize(t1)
        t22=normalize(t2)
        CurveEP(p1,p2,t11,t22)
    else
        CurveEP(p1,p2,t1,t2)
    end
end
=#
