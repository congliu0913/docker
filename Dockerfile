# install openvine_2019_R1
# install ros2 
# install opencv 3.4.2
from congliu0913/ros2:openvino_opencv_1

MAINTAINER Cong Liu congx.liu@intel.com

SHELL ["/bin/bash", "-c"]

ARG http_proxy

RUN apt-get update &&\
      apt-get install -qq -y libboost-all-dev sudo lcov
# install librealsense
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy=$http_proxy --recv-key C8B3A55A6F3EFCDE &&\
      sh -c 'echo "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo `lsb_release -cs` main" > /etc/apt/sources.list.d/librealsense.list' &&\
      apt update && apt-get install -y librealsense2-dkms librealsense2-utils librealsense2-dev
