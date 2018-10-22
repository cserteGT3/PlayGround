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

#Generating mesh from an array.
function makeMeshfromArray(vtarray,MeshType = GLNormalMesh)
    vl = size(vtarray,1)
    VertexType  = vertextype(MeshType)
    #it should be Point3f0
    FaceType    = facetype(MeshType)
    vts         = Array{VertexType}(undef, vl)
    fcs         = FaceType[]
    for i in 1:vl
        vts[i] = convert(Point3f0,vtarray[i])
    end
    return MeshType(vts,fcs)
end

#Generating mesh from matrix
function makeMeshfromMatrix(vtarray,MeshType = GLNormalMesh)
    vl = size(vtarray,1)
    VertexType  = vertextype(MeshType)
    #it should be Point3f0
    FaceType    = facetype(MeshType)
    vts         = Array{VertexType}(undef, vl)
    fcs         = FaceType[]
    for i in 1:vl
        vts[i] = convert(Point3f0,vtarray[i,:])
    end
    return MeshType(vts,fcs)
end

#Generating matrix from mesh
function makeMatrixFromMesh(meshe,fltype=FLTP)
    vts = vertices(meshe)
    vtsl = size(vts,1)
    outarr = zeros(fltype,vtsl,3)
    for i in 1:vtsl
        outarr[i,:] = convert(Array{fltype,1},vts[i])
    end
    return outarr
end