using MeshCat, FileIO, CoordinateTransformations, StaticArrays, Colors
using GeometryTypes, NearestNeighbors, RecursiveArrayTools, Distances, BenchmarkTools
using Rotations
using Logging, LinearAlgebra, Random
import MeshCat: vertices
import GeometryTypes: Point3f0
import StatsBase.self_avoid_sample!, StatsBase.mean_and_std

if MODEL_PATH_KEY == :hPC
	const MODEL_FOLDER = "C:\\Users\\Laci\\gdrive-cstamas\\BME-GPK\\Programok\\ICP-models"
elseif MODEL_PATH_KEY == :wNB
	const MODEL_FOLDER = "C:\\Users\\cstamas\\gdrive-csertegt\\BME-GPK\\Programok\\ICP-models"
elseif MODEL_PATH_KEY == :hNB
	const MODEL_FOLDER = "C:\\Users\\Istvan\\Google Drive-cstamas\\BME-GPK\\Programok\\ICP-models"
end
@info "MODEL_FOLDER set to $MODEL_FOLDER"