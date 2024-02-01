##############################################################################
##                                 Base Image                               ##
##############################################################################
# ARG ROS_DISTRO=humble
# ARG ROS_PKG=desktop-full-jammy
# FROM osrf/ros:humble-desktop-full-jammy

ARG ROS_DISTRO=melodic
ARG ROS_PKG=desktop-full-bionic
FROM osrf/ros:melodic-desktop-full-bionic

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

##############################################################################
##                                 Global Dependecies                       ##
##############################################################################
#POSIX standards-compliant default locale. Only strict ASCII characters are valid, extended to allow the basic use of UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV LC_ALL=C

RUN apt-get update && apt-get install --no-install-recommends -y \
    dirmngr gnupg2 lsb-release can-utils iproute2\
    apt-utils bash nano aptitude util-linux \
    htop git tmux sudo wget gedit bsdmainutils && \
    rm -rf /var/lib/apt/lists/*


# RUN apt-get update && apt-get install --no-install-recommends -y \
#     pip \
#     build-essential \
#     cmake \
#     libgtk2.0-dev \
#     pkg-config \
#     libavcodec-dev \
#     libavformat-dev \
#     libswscale-dev \
#     python3-dev \
#     python3-numpy \
#     libtbb2 \
#     libtbb-dev \
#     libjpeg-dev \
#     libpng-dev \
#     libtiff-dev \
#     # libdc1394-22-dev \
#     libflann-dev \
#     libboost-all-dev \
#     libqhull-dev \
#     libusb-dev \
#     libgtest-dev \
#     freeglut3-dev \
#     libxmu-dev \
#     libxi-dev \
#     libusb-1.0-0-dev \
#     graphviz \
#     mono-complete \
#     # qt-sdk \
#     openjdk-11-jdk \
#     openjdk-11-jre

##############################################################################
##                                 Create User                              ##
##############################################################################
ARG USER=robot
ARG PASSWORD=robot
ARG UID=1000
ARG GID=1000
ARG DOMAIN_ID=8
ARG VIDEO_GID=44
ENV ROS_DOMAIN_ID=${DOMAIN_ID}
ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}
RUN groupadd -g "$GID" "$USER"  && \
    useradd -m -u "$UID" -g "$GID" --shell $(which bash) "$USER" -G sudo && \
    groupadd realtime && \
    groupmod -g ${VIDEO_GID} video && \
    usermod -aG video "$USER" && \
    usermod -aG dialout "$USER" && \
    usermod -aG realtime "$USER" && \
    echo "$USER:$PASSWORD" | chpasswd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudogrp
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /etc/bash.bashrc
RUN echo "export ROS_DOMAIN_ID=${DOMAIN_ID}" >> /etc/bash.bashrc

USER $USER
RUN mkdir -p /home/$USER/ros2_ws/src

##############################################################################
##                      Data Generation Dependecies                         ##
##############################################################################
USER root

RUN apt-get update && apt-get install --no-install-recommends -y \
    g++ cmake cmake-gui doxygen mpi-default-dev openmpi-bin openmpi-common \
    libusb-1.0-0-dev libqhull* libusb-dev libgtest-dev \
    git-core freeglut3-dev pkg-config build-essential libxmu-dev libxi-dev \
    libphonon-dev libphonon-dev phonon-backend-gstreamer \
    phonon-backend-vlc graphviz mono-complete \
    qt5-default \
    libflann-dev \
    libflann1.9 \
    libboost-dev \
    libeigen3-dev \
    ros-melodic-catkin python-catkin-tools && \
    rm -rf /var/lib/apt/lists/*

USER $USER
RUN mkdir -p /home/$USER/dependecies_ws

COPY --chown=$USER:$USER thirdparty /home/$USER/dependecies_ws

# # Eigen 3.3.9
# RUN sudo cp -r eigen-3.3.9/Eigen /usr/include/

# # PCL 1.9.1
# RUN cd pcl && \
#     mkdir build && \
#     cd build && \
#     cmake -DCMAKE_BUILD_TYPE=Release .. && \
#     make -j$(nproc) && \
#     make install

# VTK 8.1.1
RUN cd /home/$USER/dependecies_ws/VTK-8.1.1 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    sudo make install

# PCL 1.9.1
RUN cd /home/$USER/dependecies_ws/pcl && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    sudo make install

# OpenCV 4.4.0
RUN cd /home/$USER/dependecies_ws/opencv && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_CXX_STANDARD=14 -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && \
    sudo make install

RUN cd /home/$USER/dependecies_ws/octomap && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    sudo make install

# RUN cd /home/$USER/dependecies_ws/gurobi911/linux64 && \
#     python setup.py install

# RUN cd ..

# # PCL 1.9.1
# RUN cd pcl && \
#     mkdir build && \
#     cd build && \
#     cmake -DCMAKE_BUILD_TYPE=Release .. && \
#     make -j$(nproc) && \
#     make install

# # # Cleanup
# # RUN apt-get clean && \
# #     rm -rf /var/lib/apt/lists/*

# USER $USER

# RUN wget https://gitlab.com/libeigen/eigen/-/archive/3.3.9/eigen-3.3.9.tar.gz && \
#     tar -xzvf eigen-3.3.9.tar.gz && \
#     cp -r eigen-3.3.9/Eigen /usr/include/ && \
#     rm -rf eigen-3.3.9.tar.gz eigen-3.3.9

# # OpenCV 4.4.0
# RUN git clone https://github.com/opencv/opencv.git && \
#     cd opencv && \
#     git checkout 4.4.0 && \
#     mkdir build && \
#     cd build && \
#     cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
#     make -j$(nproc) && \
#     make install && \
#     cd ../../ && \
#     rm -rf opencv

# PCL 1.9.1
# RUN git clone https://github.com/PointCloudLibrary/pcl.git && \
#     cd pcl && \
#     git checkout pcl-1.8.1 && \
#     mkdir build && \
#     cd build && \
#     cmake .. && \
#     make -j$(nproc) && \
#     make install && \
#     cd ../../ && \
#     rm -rf pcl

# WORKDIR /home/$USER/ros2_ws

# RUN git clone git@github.com:IRAS-HKA/iiwa_scan_planning.git

# # OctoMap 1.9.6
# RUN git clone https://github.com/OctoMap/octomap.git && \
#     cd octomap && \
#     git checkout v1.9.6 && \
#     mkdir build && \
#     cd build && \
#     cmake .. && \
#     make && \
#     make install && \
#     cd ../../ && \
#     rm -rf octomap

# RUN apt-get update && apt-get install --no-install-recommends -y \
#     libopencv-dev \
#     libpcl-dev \
#     libeigen3-dev \
#     liboctomap-dev && \
#     rm -rf /var/lib/apt/lists/*

# USER $USER
##############################################################################
##                                 Build ROS and run                        ##
##############################################################################
# WORKDIR /home/$USER/ros2_ws

CMD /bin/bash

