#include <memory>

#include <QtWidgets>

#include "MyWindow.h"

MyWindow::MyWindow(QApplication *parent) :
  QMainWindow(), parent(parent), last_directory(".")
{
  setWindowTitle(tr("Sample 3D Framework"));
  setStatusBar(new QStatusBar);
  progress = new QProgressBar;
  progress->setMinimum(0); progress->setMaximum(100);
  progress->hide();
  statusBar()->addPermanentWidget(progress);

  viewer = new MyViewer(this);
  connect(viewer, SIGNAL(startComputation(QString)), this, SLOT(startComputation(QString)));
  connect(viewer, SIGNAL(midComputation(int)), this, SLOT(midComputation(int)));
  connect(viewer, SIGNAL(endComputation()), this, SLOT(endComputation()));
  connect(viewer, SIGNAL(showResult(QString)), this, SLOT(showResult(QString)));
  connect(viewer, SIGNAL(showWarning(QString)), this, SLOT(showWarning(QString)));
  setCentralWidget(viewer);

  /////////////////////////
  // Setup actions/menus //
  /////////////////////////

  auto openAction = new QAction(tr("&Open"), this);
  openAction->setShortcut(tr("Ctrl+O"));
  openAction->setStatusTip(tr("Load a model from a file"));
  connect(openAction, SIGNAL(triggered()), this, SLOT(open()));

  auto quitAction = new QAction(tr("&Quit"), this);
  quitAction->setShortcut(tr("Ctrl+Q"));
  quitAction->setStatusTip(tr("Quit the program"));
  connect(quitAction, SIGNAL(triggered()), this, SLOT(close()));

  auto cutoffAction = new QAction(tr("Set &cutoff ratio"), this);
  cutoffAction->setStatusTip(tr("Set mean map cutoff ratio"));
  connect(cutoffAction, SIGNAL(triggered()), this, SLOT(setCutoff()));

  auto rangeAction = new QAction(tr("Set &range"), this);
  rangeAction->setStatusTip(tr("Set mean map range"));
  connect(rangeAction, SIGNAL(triggered()), this, SLOT(setRange()));

  auto saveAction = new QAction(tr("&Save"), this);
  saveAction->setShortcut(tr("Ctrl+B"));
  saveAction->setStatusTip(tr("Save bézier surface."));
  connect(saveAction, SIGNAL(triggered()), this, SLOT(saveFile()));

  auto fileMenu = menuBar()->addMenu(tr("&File"));
  fileMenu->addAction(openAction);
  fileMenu->addAction(saveAction);
  fileMenu->addAction(quitAction);


  auto visMenu = menuBar()->addMenu(tr("&Visualization"));
  visMenu->addAction(cutoffAction);
  visMenu->addAction(rangeAction);
}

MyWindow::~MyWindow() {
}

void MyWindow::open() {
  auto filename =
    QFileDialog::getOpenFileName(this, tr("Open File"), last_directory,
                                 tr("All files (*.*);;"
                                     "Mesh (*.obj *.ply *.stl);;"
                                    "Bézier surface (*.bzr)"
                                    ));
  if(filename.isEmpty())
    return;
  last_directory = QFileInfo(filename).absolutePath();

  bool ok;
  if (filename.endsWith(".bzr"))
    ok = viewer->openBezier(filename.toUtf8().data());
  else
    ok = viewer->openMesh(filename.toUtf8().data());

  if (!ok)
    QMessageBox::warning(this, tr("Cannot open file"),
                         tr("Could not open file: ") + filename + ".");
}

void MyWindow::setCutoff() {
  // Memory management options for the dialog:
  // - on the stack (deleted at the end of the function)
  // - on the heap with manual delete or std::unique_ptr 
  // There is also a Qt-controlled automatic deletion by calling
  //     dlg->setAttribute(Qt::WA_DeleteOnClose);
  // ... but this could delete sub-widgets too early.

  auto dlg = std::make_unique<QDialog>(this);
  auto *hb1    = new QHBoxLayout,
       *hb2    = new QHBoxLayout;
  auto *vb     = new QVBoxLayout;
  auto *text   = new QLabel(tr("Cutoff ratio:"));
  auto *sb     = new QDoubleSpinBox;
  auto *cancel = new QPushButton(tr("Cancel"));
  auto *ok     = new QPushButton(tr("Ok"));

  sb->setDecimals(3);
  sb->setRange(0.001, 0.5);
  sb->setSingleStep(0.01);
  sb->setValue(viewer->getCutoffRatio());
  connect(cancel, SIGNAL(pressed()), dlg.get(), SLOT(reject()));
  connect(ok,     SIGNAL(pressed()), dlg.get(), SLOT(accept()));
  ok->setDefault(true);

  hb1->addWidget(text);
  hb1->addWidget(sb);
  hb2->addWidget(cancel);
  hb2->addWidget(ok);
  vb->addLayout(hb1);
  vb->addLayout(hb2);

  dlg->setWindowTitle(tr("Set ratio"));
  dlg->setLayout(vb);

  if(dlg->exec() == QDialog::Accepted) {
    viewer->setCutoffRatio(sb->value());
    viewer->update();
  }
}

void MyWindow::setRange() {
  QDialog dlg(this);
  auto *grid   = new QGridLayout;
  auto *text1  = new QLabel(tr("Min:")),
       *text2  = new QLabel(tr("Max:"));
  auto *sb1    = new QDoubleSpinBox,
       *sb2    = new QDoubleSpinBox;
  auto *cancel = new QPushButton(tr("Cancel"));
  auto *ok     = new QPushButton(tr("Ok"));

  // The range of the spinbox controls the number of displayable digits,
  // so setting it to a large value results in a very wide window.
  double max = 1000.0; // std::numeric_limits<double>::max();
  sb1->setDecimals(5);                 sb2->setDecimals(5);
  sb1->setRange(-max, 0.0);            sb2->setRange(0.0, max);
  sb1->setSingleStep(0.01);            sb2->setSingleStep(0.01);
  sb1->setValue(viewer->getMeanMin()); sb2->setValue(viewer->getMeanMax());
  connect(cancel, SIGNAL(pressed()), &dlg, SLOT(reject()));
  connect(ok,     SIGNAL(pressed()), &dlg, SLOT(accept()));
  ok->setDefault(true);

  grid->addWidget( text1, 1, 1, Qt::AlignRight);
  grid->addWidget(   sb1, 1, 2);
  grid->addWidget( text2, 2, 1, Qt::AlignRight);
  grid->addWidget(   sb2, 2, 2);
  grid->addWidget(cancel, 3, 1);
  grid->addWidget(    ok, 3, 2);

  dlg.setWindowTitle(tr("Set range"));
  dlg.setLayout(grid);

  if(dlg.exec() == QDialog::Accepted) {
    viewer->setMeanMin(sb1->value());
    viewer->setMeanMax(sb2->value());
    viewer->update();
  }
}

void MyWindow::startComputation(QString message) {
  statusBar()->showMessage(message);
  progress->setValue(0);
  progress->show();
  parent->processEvents(QEventLoop::ExcludeUserInputEvents);
}

void MyWindow::midComputation(int percent) {
  progress->setValue(percent);
  parent->processEvents(QEventLoop::ExcludeUserInputEvents);
}

void MyWindow::endComputation() {
  progress->hide();
  statusBar()->clearMessage();
}

void MyWindow::showResult(QString msg) {
    auto dlg = std::make_unique<QDialog>(this);
    auto *vertl = new QVBoxLayout;
    auto *text = new QLabel(msg);
    auto *ok = new QPushButton(tr("Thank you!"));
    connect(ok, SIGNAL(pressed()), dlg.get(), SLOT(accept()));
    ok->setDefault(true);
    vertl->addWidget(text);
    vertl->addWidget(ok);
    dlg->setWindowTitle(tr("Results"));
    dlg->setLayout(vertl);
    if(dlg->exec() == QDialog::Accepted){
        viewer->update();
    }
}

void MyWindow::showWarning(QString msg) {
    auto dlg = std::make_unique<QDialog>(this);
    auto *vertl = new QVBoxLayout;
    auto *text = new QLabel(msg);
    auto *ok = new QPushButton(tr("Sad panda is sad!"));
    connect(ok, SIGNAL(pressed()), dlg.get(), SLOT(accept()));
    ok->setDefault(true);
    vertl->addWidget(text);
    vertl->addWidget(ok);
    dlg->setWindowTitle(tr("Warning"));
    dlg->setLayout(vertl);
    if(dlg->exec() == QDialog::Accepted){
        viewer->update();
    }
}

void MyWindow::saveFile() {
    bool nogo = viewer->meshIsEmpty();
    if ( nogo )
    {
        showWarning(tr("Open a file before saving it!"));
    }else if ( viewer->model_type != viewer->ModelType::BEZIER_SURFACE )
    {
        showWarning(tr("Only Bézier surfaces can be saved!"));
    }
    else
    {
      auto filename =
        QFileDialog::getSaveFileName(this, tr("Save File"), last_directory,
                                     tr("Bézier surface (*.bzr);;"
                                        "All files (*.*)"));
      if(filename.isEmpty())
        return;
      last_directory = QFileInfo(filename).absolutePath();

      bool ok = true;
      if (filename.endsWith(".bzr"))
        //ok = viewer->saveBezier(filename.toUtf8().data());
          ok = viewer->saveBezier(filename);
      else
          QMessageBox::warning(this, tr("Can not save file."),
                               tr("File name must end: *.bzr"));

      if (!ok)
        QMessageBox::warning(this, tr("Can not save file"),
                             tr("Could not save file: ") + filename + ".");
    }
}
