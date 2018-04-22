double MyViewer::getCutoffRatio() const {
  return cutoff_ratio;
}

void MyViewer::setCutoffRatio(double ratio) {
  cutoff_ratio = ratio;
  updateMeanMinMax();
}

double MyViewer::getMeanMin() const {
  return mean_min;
}

void MyViewer::setMeanMin(double min) {
  mean_min = min;
}

double MyViewer::getMeanMax() const {
  return mean_max;
}

void MyViewer::setMeanMax(double max) {
  mean_max = max;
}

//Distance from origo
double MyViewer::distanceOrigo(MyMesh::VertexIter vert) {
    MyMesh::Point poV = mesh.point(*vert);
    double ll = poV[0]*poV[0]+poV[1]*poV[1]+poV[2]*poV[2];
    return qSqrt(ll);
}

//Returns false if there's no vertice in mesh, true otherwise
bool MyViewer::meshIsEmpty() {
    if( mesh.n_vertices() == 0)
        return true;
    return false;
}
