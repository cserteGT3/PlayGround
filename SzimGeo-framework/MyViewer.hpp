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
    MyMesh::VertexIter v_it,v_end(mesh.vertices_end());
    int numb = 0;
    bool empty = true;
    for (v_it=mesh.vertices_begin(); v_it!=v_end; ++v_it)
    {
        ++numb;
        if (numb > 0)
        {
            empty = false;
            break;
        }
    }
    return empty;
}
