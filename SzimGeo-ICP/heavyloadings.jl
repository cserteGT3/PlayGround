using MeshCat, FileIO, Interact, CoordinateTransformations, StaticArrays, Logging, Colors
import MeshCat: vertices
#make a visualizer
vis = Visualizer();
@info "Visualizer started: vis"

if MODEL_PATH_KEY == :hPC
	const MODEL_FOLDER = "C:\\Users\\Pista\\Google Drive\\BME-GPK\\Programok\\ICP-models"
elseif MODEL_PATH_KEY == :wNB
	const MODEL_FOLDER = "C:\\Users\\cstamas\\gdrive-csertegt\\BME-GPK\\Programok\\ICP-models"
elseif MODEL_PATH_KEY == :hNB
	const MODEL_FOLDER = "C:\\Users\\Istvan\\Google Drive-cstamas\\BME-GPK\\Programok\\ICP-models"
end
@info "MMODEL_FOLDER set to $MODEL_FOLDER"