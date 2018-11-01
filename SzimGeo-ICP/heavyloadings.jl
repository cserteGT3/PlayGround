using MeshCat, FileIO, Interact, CoordinateTransformations, StaticArrays, Colors
using GeometryTypes, NearestNeighbors, RecursiveArrayTools, Distances, BenchmarkTools
using Logging, LinearAlgebra, Random
import MeshCat: vertices
import GeometryTypes: Point3f0
import StatsBase.self_avoid_sample!
#make a visualizer
vis = Visualizer();
@info "Visualizer started: vis"

if MODEL_PATH_KEY == :hPC
	const MODEL_FOLDER = "C:\\Users\\Laci\\gdrive-cstamas\\BME-GPK\\Programok\\ICP-models"
elseif MODEL_PATH_KEY == :wNB
	const MODEL_FOLDER = "C:\\Users\\cstamas\\gdrive-csertegt\\BME-GPK\\Programok\\ICP-models"
elseif MODEL_PATH_KEY == :hNB
	const MODEL_FOLDER = "C:\\Users\\Istvan\\Google Drive-cstamas\\BME-GPK\\Programok\\ICP-models"
end
@info "MODEL_FOLDER set to $MODEL_FOLDER"