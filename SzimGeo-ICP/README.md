# Szimgeo-ICP

This folder is for a project involving ICP (Iterative Closest Point) algorithms, meshes and pointclouds. This readme is only for a light documentation.
Currently only `Float32` is used, because the mesh type used by the packages.

## Used packages
* **IJulia** - for the Jupyter IDE
* **MeshCat** - for visualizing meshes and pointclouds
* **MeshIO, FileIO** - for loading .ply files
* **Interact** - for easypeasy widgets
* **CoordinaTransformations** - for obvious reasons
* **StaticArrays** - for fast arrays and matrices
* **Colors** - for visualizing different pointclouds
* **NearestNeighbors** - for k-d tree
* **Distances** - needed for the above package, and it's awesome on it's own
* **GeometryTypes** - for creating meshes
* **StatsBase** - for random sampling
* **BenchmarkTools** - for benchmarking
* **RecursiveArrayTools** - instead of `vcat(A...)`

For a little help:

`add MeshCat FileIO MeshIO Interact CoordinaTransformations StaticArrays Colors NearestNeighbors GeometryTypes StatsBase BenchmarkTools RecursiveArrayTools``

## Used packages that are part of Julia's stdlib
* **Logging** - instead of `println()`
* **Markdown** - for debugging this readme
* **LinearAlgebra** - for obvious reasons
* **Random** - for obvious reasons

This readme can be displayed with: `using Markdown; Markdown.parse_file("README.md")`

And here's a help for [Github Markdown](https://guides.github.com/features/mastering-markdown/)

### TODOs:
* Remove Random pkg if not needed
* Create a dummy ICP case, which compiles all the functions.