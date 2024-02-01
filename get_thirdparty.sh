#!/bin/sh

cd thirdparty

git clone https://github.com/opencv/opencv.git
cd opencv
git checkout 4.4.0 

cd ..
git clone https://github.com/PointCloudLibrary/pcl.git
cd pcl
git checkout pcl-1.8.1

cd ..
git clone https://github.com/OctoMap/octomap.git
cd octomap && \
git checkout v1.9.6

cd ..
wget http://www.vtk.org/files/release/8.1/VTK-8.1.1.tar.gz
tar -zxvf VTK-8.1.1.tar.gz
rm -rf VTK-8.1.1.tar.gz

cd ../..