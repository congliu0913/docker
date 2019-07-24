# install openvine_2019_R1
# install ros2 
from ubuntu:bionic

MAINTAINER Cong Liu congx.liu@intel.com

SHELL ["/bin/bash", "-c"]

ARG http_proxy
RUN useradd --create-home --no-log-init --shell /bin/bash --password robot robot
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \ 
      vim \
      wget \
      build-essential \
      git \
      cmake \
      python3-pip \
      python-pip \
      curl \
      gnupg2 \
      lsb-release \
      sudo \
      python-sphinx &&\
      rm -rf /var/lib/apt/lists/*
RUN pip install sphinx_rtd_theme

RUN apt-get update && apt-get install --no-install-recommends -y locales \
	lsb-release
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt update && apt install -y curl gnupg2
RUN curl http://repo.ros2.org/repos.key | apt-key add -
RUN sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy=$http_proxy --recv-key F42ED6FBAB17C654

#ENV DEBIAN_FRONTEND=noninteractive

RUN DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
 	build-essential \
	cmake \
	git \
	python3-colcon-common-extensions \
	python3-pip \
	python-rosdep \
	python3-vcstool \
	cmake \
	python3-lark-parser \
	python3-lxml \
	python3-numpy \
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
	pytest-rerunfailures \
	pytest-cov \
	pytest-runner \
	setuptools
RUN apt install --no-install-recommends -y \
	libasio-dev \
	libtinyxml2-dev

ENV ROS2_WS /home/robot/ros2_ws
RUN rosdep init
RUN python3 -m pip uninstall pytest -y
RUN mkdir -p $ROS2_WS/src
WORKDIR $ROS2_WS
RUN wget https://raw.githubusercontent.com/ros2/ros2/release-dashing-20190614/ros2.repos
RUN vcs import src < ros2.repos
WORKDIR $ROS2_WS
RUN rosdep update &&rosdep install --from-paths src --ignore-src --rosdistro dashing -y --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers"
RUN colcon build --symlink-install
WORKDIR /tmp

# opencl
WORKDIR /home/robot/code
RUN mkdir -p OpenCl/intel-opencl
WORKDIR /home/robot/code/OpenCl/
RUN wget -c https://github.com/intel/compute-runtime/releases/download/19.04.12237/intel-gmmlib_18.4.1_amd64.deb &&\
    wget -c https://github.com/intel/compute-runtime/releases/download/19.04.12237/intel-igc-core_18.50.1270_amd64.deb &&\
    wget -c https://github.com/intel/compute-runtime/releases/download/19.04.12237/intel-igc-opencl_18.50.1270_amd64.deb &&\
    wget -c https://github.com/intel/compute-runtime/releases/download/19.04.12237/intel-opencl_19.04.12237_amd64.deb &&\
    wget -c https://github.com/intel/compute-runtime/releases/download/19.04.12237/intel-ocloc_19.04.12237_amd64.deb &&\
    dpkg -i ./*.deb

# openvino
WORKDIR /home/robot/code
RUN mkdir -p openvino_binart
RUN apt-get install -y cpio
RUN wget -c http://registrationcenter-download.intel.com/akdlm/irc_nas/15512/l_openvino_toolkit_p_2019.1.144.tgz &&\
    tar -xvf l_openvino_toolkit_p_2019.1.144.tgz &&\
    cd l_openvino_toolkit_p_2019.1.144 &&\
    ./install_openvino_dependencies.sh &&\
    sed -i 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg &&\
    ./install.sh --silent silent.cfg

RUN . /opt/intel/openvino/bin/setupvars.sh &&\
    mkdir -p /home/robot/code/openvino_binart_example &&\
    cd /home/robot/code/openvino_binart_example &&\
    mkdir -p build && cd build &&\
    cmake /opt/intel/openvino/deployment_tools/inference_engine/samples/ && make && cd .. &&\
    /bin/cp -rf build /opt/intel/openvino/deployment_tools/inference_engine/samples/

RUN apt-get update && apt-get -y -qq dist-upgrade
