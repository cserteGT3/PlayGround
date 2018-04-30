// -*- mode: c++ -*-
#pragma once

#include <string>

#include <QGLViewer/qglviewer.h>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>
#include <OpenMesh/Core/Mesh/TriConnectivity.hh>
#include <OpenMesh/Core/Mesh/TriMeshT.hh>
#include <QtMath>
#include <QTextStream>

using qglviewer::Vec;

class MyViewer : public QGLViewer {
  Q_OBJECT

public:
  explicit MyViewer(QWidget *parent);
  virtual ~MyViewer();

  inline double getCutoffRatio() const;
  inline void setCutoffRatio(double ratio);
  inline double getMeanMin() const;
  inline void setMeanMin(double min);
  inline double getMeanMax() const;
  inline void setMeanMax(double max);
  bool openMesh(const std::string &filename);
  bool openBezier(const std::string &filename);
  bool saveBezier(QString filename);
  enum class ModelType { NONE, MESH, BEZIER_SURFACE } model_type;
  inline bool meshIsEmpty();

signals:
  void startComputation(QString message);
  void midComputation(int percent);
  void endComputation();
  void showResult(QString msg);
  void showWarning(QString msg);

protected:
  virtual void init() override;
  virtual void draw() override;
  virtual void drawWithNames() override;
  virtual void postSelection(const QPoint &p) override;
  virtual void keyPressEvent(QKeyEvent *e) override;
  virtual void mouseMoveEvent(QMouseEvent *e) override;
  virtual QString helpString() const override;

private:
  struct MyTraits : public OpenMesh::DefaultTraits {
    using Point  = OpenMesh::Vec3d; // the default would be Vec3f
    using Normal = OpenMesh::Vec3d;
    VertexTraits {
      double mean;              // approximated mean curvature
      double up,vp;             // u and v parameters
    };
  };
  using MyMesh = OpenMesh::TriMesh_ArrayKernelT<MyTraits>;
  using Vector = OpenMesh::VectorT<double,3>;

  // Mesh
  void updateMesh(bool update_mean_range = true);
  void updateVertexNormals();
  void localSystem(const Vector &normal, Vector &u, Vector &v);
  double voronoiWeight(MyMesh::HalfedgeHandle in_he);
  void updateMeanMinMax();
  void updateMeanCurvature(bool update_min_max = true);

  // Bezier
  static void bernsteinAll(size_t n, double u, std::vector<double> &coeff);
  void generateMesh();

  // Visualization
  void setupCamera();
  Vec meanMapColor(double d) const;
  void drawControlNet() const;
  void drawAxes() const;
  void drawAxesWithNames() const;
  static Vec intersectLines(const Vec &ap, const Vec &ad, const Vec &bp, const Vec &bd);

  // Other
  void fairMesh();

  // Homework URLGNI
  void searchOrigo();
  inline double distanceOrigo(MyMesh::VertexIter vert);
  bool show_nearest, is_empty;
  QList<MyMesh::VertexFaceIter> near_faces;
  void elevateDegree();
  void continuesMean();
  //////////////////////
  // Member variables //
  //////////////////////

  // Mesh
  MyMesh mesh;

  // Bezier
  size_t degree[2];
  std::vector<Vec> control_points;

  // Visualization
  double mean_min, mean_max, cutoff_ratio;
  bool show_control_points, show_solid, show_wireframe;
  enum class Visualization { PLAIN, MEAN, ISOPHOTES } visualization;
  GLuint isophote_texture;
  int selected_vertex;
  struct ModificationAxes {
    bool shown;
    float size;
    int selected_axis;
    Vec position, grabbed_pos, original_pos;
  } axes;
};

#include "MyViewer.hpp"
