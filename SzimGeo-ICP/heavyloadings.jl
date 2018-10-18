using MeshCat, FileIO, Interact, CoordinateTransformations, StaticArrays, Logging, Colors
import MeshCat: vertices
#make a visualizer and load the bunny model with the :fbunny keyword
vis = Visualizer();
@info "Visualizer started: vis"

function setModelPath(key)
    if key == :homePC
        global const MODEL_FOLDER = "C:\\Users\\Pista\\Google Drive\\BME-GPK\\Programok\\ICP-models"
	elseif key == :wNB
		global const MODEL_FOLDER = "C:\Users\cstamas\gdrive-csertegt\BME-GPK\Programok\ICP-models"
    end
    @info "MODEL_FOLDER is set to: $MODEL_FOLDER"
end