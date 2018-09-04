########################################################
# Dockerfile to setup base container image for coverity and protex scan
# Based on Ubuntu 16.04
########################################################

# Set the base image to Ubuntu 16.04

FROM otc-rse/ubuntu1604:coverity_and_protex_base_install

MAINTAINER Liu Cong "congx.liu@intel.com"

ENV http_proxy http://child-prc.intel.com:913
ENV https_proxy http://child-prc.intel.com:913
ENV ftp_proxy ftp://child-prc.intel.com:913

ADD sudoers /etc/sudoers
ADD pip.conf /root/.pip/pip.conf
ADD pip.conf /home/robot/.pip/pip.conf

RUN apt-get update && apt-get install --no-install-recommends -y locales \
	lsb-release
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt update && apt install curl
RUN curl http://repo.ros2.org/repos.key | apt-key add -
RUN sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && sudo apt install -y \
 	build-essential \
	cmake \
	git \
	python3-colcon-common-extensions \
	python3-pip \
	python-rosdep \
	python3-vcstool \
	wget
RUN python3 -m pip install -U \
	argcomplete \
	flake8 \
	flake8-blind-except \
	flake8-builtins \
	flake8-class-newline \
	flake8-comprehensions \
	flake8-deprecated \
	flake8-docstrings \
	flake8-import-order \
	flake8-quotes \
	pytest-repeat \
	pytest-rerunfailures
RUN python3 -m pip install -U \
	pytest \
	pytest-cov \
	pytest-runner \
	setuptools
RUN apt install --no-install-recommends -y \
	libasio-dev \
	libtinyxml2-dev

RUN apt install -y --no-install-recommends \
	libeigen3-dev \
	libtinyxml2-dev \
	qtbase5-dev \
	libfreetype6 \
	libfreetype6-dev \
	libyaml-dev \
	libconsole-bridge-dev \
	libcurl4-openssl-dev \
	curl \
	libxaw7-dev \
	libcppunit-dev \
	libpcre3-dev \
	cmake \
	clang-format \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	python3-flake8 \
	pyflakes3 \
	cppcheck \
	libxrandr-dev \
	libqt5core5a \
	libqt5widgets5 \
	python-mock \
	python3-pkg-resources \
	libxml2-utils \
	libopencv-dev \
	libtinyxml-dev \
	python3-yaml \
	uncrustify \
	libqt5opengl5 \
	python3-mock \
	python3-pytest \
	openssl \
	python3-pep8 \
	libassimp-dev \
	libpoco-dev \
	pydocstyle \
	zlib1g-dev \
	python3-empy \
	libx11-dev \
	libqt5gui5 \
	python3-setuptools \
	python3-catkin-pkg-modules \
	pkg-config


ENV ROS2_WS /home/robot/ros2_ws
USER robot
ENV http_proxy http://child-prc.intel.com:913
ENV https_proxy http://child-prc.intel.com:913
ENV ftp_proxy ftp://child-prc.intel.com:913
RUN mkdir -p $ROS2_WS/src
WORKDIR $ROS2_WS
RUN wget https://raw.githubusercontent.com/ros2/ros2/master/ros2.repos
RUN vcs import src < ros2.repos
WORKDIR $ROS2_WS
RUN colcon build --symlink-install
WORKDIR /tmp
USER root
RUN mkdir -p /home/robot/code/
WORKDIR /home/robot/code/
RUN wget https://ncs-forum-uploads.s3.amazonaws.com/ncsdk/ncsdk-01_12_00_01-full/ncsdk-1.12.00.01.tar.gz
RUN tar -zxvf ncsdk-1.12.00.01.tar.gz
RUN mv ncsdk-1.12.00.01 ncsdk 
RUN git clone https://github.com/movidius/ncappzoo
RUN lsb_release -a
RUN ls
RUN cd /home/robot/code/ncsdk/ && make install
RUN sudo ln -s /home/robot/code/ncappzoo /opt/movidius/ncappzoo
RUN ln -s /usr/lib/x86_64-linux-gnu/libusb.a /usr/lib/libusb.a
ENV http_proxy http://child-prc.intel.com:913
ENV https_proxy http://child-prc.intel.com:913
ENV ftp_proxy ftp://child-prc.intel.com:913
WORKDIR /home/robot/code
RUN git clone https://github.com/opencv/opencv
RUN git clone https://github.com/opencv/opencv_contrib
RUN pwd
WORKDIR /home/robot
RUN wget https://raw.githubusercontent.com/opencv/opencv_3rdparty/a62e20676a60ee0ad6581e217fe7e4bada3b95db/ippicv/ippicv_2017u2_lnx_intel64_20170418.tgz
RUN mkdir /home/robot/code/opencv/.cache/ippicv/ -p
RUN mv /home/robot/ippicv_2017u2_lnx_intel64_20170418.tgz /home/robot/code/opencv/.cache/ippicv/87cbdeb627415d8e4bc811156289fa3a-ippicv_2017u2_lnx_intel64_20170418.tgz
WORKDIR /home/robot/code/opencv
RUN git checkout 3.3.0 && cd ../opencv_contrib/ && git checkout 3.3.0
RUN mkdir build && cd build
WORKDIR /home/robot/code/opencv/build
RUN cmake -DOPENCV_EXTRA_MODULES_PATH=/home/robot/code/opencv_contrib/modules -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_opencv_cnn_3dobj=OFF ..
RUN make -j12
RUN make install
RUN ldconfig
RUN cd /usr/lib/x86_64-linux-gnu && ln -s libboost_python-py35.so libboost_python3.so
RUN apt-get install  -y libudev-dev         pkg-config         libgtk-3-dev         libglfw3-dev         libusb-1.0
WORKDIR /home/robot/code
RUN git clone https://github.com/IntelRealSense/librealsense.git
RUN cd librealsense && git checkout v2.14.1 && git branch -a
WORKDIR /home/robot/code/librealsense
RUN mkdir build &&cd build
WORKDIR /home/robot/code/librealsense/build
RUN cmake ../ -DBUILD_EXAMPLES=true
RUN make uninstall && make clean && make -j12 && sudo make install
RUN mkdir /etc/udev/rules.d
RUN cd ../ && cp config/99-realsense-libusb.rules /etc/udev/rules.d/
RUN ldconfig
WORKDIR /home/robot/
RUN apt-get update
RUN apt-get install -y python3-numpy  libboost-python1.58.0 
