// -*- mode: c++ -*-
#pragma once

#include <QtWidgets/QMainWindow>

#include "MyViewer.h"

class QApplication;
class QProgressBar;

class MyWindow : public QMainWindow {
  Q_OBJECT

public:
  explicit MyWindow(QApplication *parent);
  ~MyWindow();

private slots:
  void open();
  void saveFile();
  void setCutoff();
  void setRange();
  void startComputation(QString message);
  void midComputation(int percent);
  void endComputation();
  void showResult(QString msg);
  void showWarning(QString msg);

private:
  QApplication *parent;
  MyViewer *viewer;
  QProgressBar *progress;
  QString last_directory;
};
