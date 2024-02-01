#!/bin/sh
uid=$(eval "id -u")
gid=$(eval "id -g")

# Mac user:
# uid=1000
# gid=1000

docker build --build-arg UID="$uid" --build-arg GID="$gid" -t data_generation/ros1:melodic .
echo "Run Container"
xhost + local:root

docker run --name data_generation_ros1 --privileged -it -e DISPLAY=$DISPLAY \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v ~/.Xauthority:/home/robot/.Xauthority \
-v $(pwd)/ros2_home:/home/robot/ \
-v $(pwd)/src:/home/robot/ros2_ws/src \
--net host --rm --ipc host data_generation/ros1:melodic

# -v $(pwd)/ros2_home:/home/robot/ \
# -v $(pwd)/src:/home/robot/ros2_ws/src \