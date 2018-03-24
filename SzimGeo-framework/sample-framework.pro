# -*- mode: Makefile -*-

TARGET = sample-framework
CONFIG *= qt opengl debug
QT += gui widgets opengl xml

HEADERS = MyWindow.h MyViewer.h MyViewer.hpp
SOURCES = MyWindow.cpp MyViewer.cpp main.cpp

INCLUDEPATH += ../libQGLViewer-2.6.3
# LIBS *= -L../libQGLViewer-2.6.3/QGLViewer -lQGLViewer -L/usr/lib/OpenMesh -lOpenMeshCored -lGL -lGLU
LIBS *= -lQGLViewer-qt5 -L/home/ltam/Letöltések/OpenMesh/build/Build/lib -lOpenMeshCored -lGL -lGLU

QMAKE_CXXFLAGS += -std=c++14

RESOURCES = sample-framework.qrc
