using MeshCat, FileIO, Interact, CoordinateTransformations, StaticArrays, Logging
import MeshCat: vertices
#load full bunny model from the folder next to the notebook file
full_bunny = load("bunny\\reconstruction\\bun_zipper.ply");
@info "Bunny loaded to full_bunny"
#make a visualizer and load the bunny model with the :fbunny keyword
vis = Visualizer();
setobject!(vis[:fbunny],full_bunny);
@info "Visualizer: vis with :fbunny"