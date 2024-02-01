# data_generation
This is a repository for SCVP data generation

## Usage
This repository has two different docker images, one is for the original SCVP [data_generation](https://github.com/psc0628/SCVP-Simulation) with opencv 4.4.0, PCL 1.9.1, Eigen 3.3.9, OctoMap 1.9.6, Gurobi 9.1.1.

```
source get_thirdparty.sh

source start_docker.sh
```
(please comment "docker build" line out in the start_docker.sh to avoid compiling the dependencies everytime)

The other one is for the modified SCVP data generation with current dependencies(ros2 humble, PCL 1.12...)

```
# RUN apt-get update && apt-get install --no-install-recommends -y \
#     libopencv-dev \
#     libpcl-dev \
#     libeigen3-dev \
#     liboctomap-dev && \
#     rm -rf /var/lib/apt/lists/*
```
Put these line back and comment the other lines in this block out to keep pace with the lastest trends:) 

```
ARG ROS_DISTRO=melodic
ARG ROS_PKG=desktop-full-bionic

ARG ROS_DISTRO=humble
ARG ROS_PKG=desktop-full-jammy
```
Get humble and jammy to change base image to ROS2.

## Authors and acknowledgment
Yucheng Tang (Yucheng-Tang)

## Project status
opened