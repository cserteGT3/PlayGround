# -*- mode: Makefile -*-

TARGET = sample-framework
CONFIG *= qt opengl debug
QT += gui widgets opengl xml

HEADERS = MyWindow.h MyViewer.h MyViewer.hpp
SOURCES = MyWindow.cpp MyViewer.cpp main.cpp

#VM on BME Cloud
#INCLUDEPATH += /home/cloud/libQGLViewer-2.6.3
#LIBS *= -L/home/cloud/libQGLViewer-2.6.3/QGLViewer -lQGLViewer -L/usr/lib/OpenMesh -lOpenMeshCored -lGL -lGLU

#Linux on my local pc
LIBS *= -lQGLViewer-qt5 -L/home/ltam/Letöltések/OpenMesh/build/Build/lib -lOpenMeshCored -lGL -lGLU


QMAKE_CXXFLAGS += -std=c++14

RESOURCES = sample-framework.qrc
