# Szimgeo-ICP

This folder is for a project involving ICP (Iterative Closest Point) algorithms, meshes and pointclouds. This readme is only for a light documentation.

Packages that I use:
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

Packages that I use and part of Julia's stdlib
* **Logging** - instead of `println()`
* **Markdown** - for debugging this readme
* **LinearAlgebra** - for obvious reasons

This readme can be displayed with: `using Markdown; Markdown.parse_file("README.md")`

And here's a help for [Github Markdown](https://guides.github.com/features/mastering-markdown/)