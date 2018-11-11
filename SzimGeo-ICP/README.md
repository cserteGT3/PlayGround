# Szimgeo-ICP

This folder is for a project involving ICP (Iterative Closest Point) algorithms, meshes and pointclouds. This readme is only for a light documentation.
Currently only `Float32` is used, because the mesh type used by the packages.

## Used packages
* **IJulia** - for the Jupyter IDE
* **MeshCat** - for visualizing meshes and pointclouds - [GitHub](https://github.com/rdeits/MeshCat.jl), [demo notebook](https://github.com/rdeits/MeshCat.jl/blob/master/demo.ipynb)
* **MeshIO, FileIO** - for loading .ply files
* **Interact** - for easypeasy widgets - [doc](https://juliagizmos.github.io/Interact.jl/latest/)
* **CoordinateTransformations** - for obvious reasons - [GitHub](https://github.com/FugroRoames/CoordinateTransformations.jl)
* **StaticArrays** - for fast arrays and matrices - [GitHub](https://github.com/JuliaArrays/StaticArrays.jl), [doc](http://juliaarrays.github.io/StaticArrays.jl/stable/)
* **Colors** - for visualizing different pointclouds - [doc](http://juliagraphics.github.io/Colors.jl/stable/), [named colors](http://juliagraphics.github.io/Colors.jl/stable/namedcolors.html)
* **NearestNeighbors** - for k-d tree - [GitHub](https://github.com/KristofferC/NearestNeighbors.jl)
* **Distances** - needed for the above package, and helps debugging - [GitHub](https://github.com/JuliaStats/Distances.jl)
* **GeometryTypes** - for creating meshes - [doc](http://juliageometry.github.io/GeometryTypes.jl/latest/)
* **StatsBase** - for random sampling - [doc](http://juliastats.github.io/StatsBase.jl/stable/)
* **BenchmarkTools** - for benchmarking - [GitHub](https://github.com/JuliaCI/BenchmarkTools.jl), [intro](https://github.com/JuliaCI/BenchmarkTools.jl/blob/master/doc/manual.md)
* **RecursiveArrayTools** - instead of `vcat(A...)` - [GitHub](https://github.com/JuliaDiffEq/RecursiveArrayTools.jl), [StackOverflow issue](https://stackoverflow.com/questions/47021821/julia-flattening-array-of-array-tuples)
* **Rotations** - for easy rotation matrixes - [GitHub](https://github.com/FugroRoames/CoordinateTransformations.jl)

For a little help:

`add MeshCat FileIO MeshIO Interact Rotations CoordinateTransformations StaticArrays Colors Distances NearestNeighbors GeometryTypes StatsBase BenchmarkTools RecursiveArrayTools`

## Used packages that are part of Julia's stdlib
* **Logging** - instead of `println()`
* **Markdown** - for debugging this readme - [julia documentation](https://docs.julialang.org/en/v1/manual/documentation/), [GitHub help](https://guides.github.com/features/mastering-markdown/)
* **LinearAlgebra** - for obvious reasons - [doc](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/)
* **Random** - for obvious reasons - [doc](https://docs.julialang.org/en/v1/stdlib/Random/)

## Useful links for myself
* [documentation of Arrays](https://docs.julialang.org/en/v1/manual/arrays/)

This readme can be displayed with: `using Markdown; Markdown.parse_file("README.md")`

This repository is edited on Windows. Therefore my git client handles the line endings (Checkout Windows-style, commit Unix-style line endings).

### TODOs:
- [x] Remove Random pkg if not needed
- [ ] Create a dummy ICP case, which compiles all the functions
- [ ] Add `@inbounds` and `@inlined` macro
- [ ] Proper `AssertionError` messages
- [ ] Index based ICP instead of copying
- [ ] Inherit array's type, size, element type
- [ ] Check if @view makes sense here 