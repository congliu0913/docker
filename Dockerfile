# moveit/moveit_example_apps:random_pick_place
# install openvine_R5
from moveit/moveit:master-source

MAINTAINER Cong Liu congx.liu@intel.com

SHELL ["/bin/bash", "-c"]

ARG http_proxy
RUN useradd --create-home --no-log-init --shell /bin/bash --password robot robot
ENV ROS1_DISTRO melodic
RUN apt-get update && apt-get install -y \
      ros-$ROS1_DISTRO-rosdoc-lite &&\
      rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \ 
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

# install openvino 
WORKDIR /home/robot/code
RUN mkdir -p openvino_binart &&cd openvino_binart && \
    apt-get update && apt-get install -y cpio && \
      rm -rf /var/lib/apt/lists/* &&\
    # wget openvino_R5
    wget -c http://registrationcenter-download.intel.com/akdlm/irc_nas/15078/l_openvino_toolkit_p_2018.5.455.tgz && \
    tar -xvf l_openvino_toolkit_p_2018.5.455.tgz &&rm l_openvino_toolkit_p_2018.5.455.tgz && \
    cd l_openvino_toolkit_p_2018.5.455 && \
    ./install_cv_sdk_dependencies.sh &&\
    sed -i 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg &&\
    ./install.sh --silent silent.cfg &&\
    # install dependencies
    cd /opt/intel/computer_vision_sdk/install_dependencies &&\
    ./install_NEO_OCL_driver.sh &&\
    # build example
    cd /home/robot/code &&\
    mkdir -p openvino_binart_example/build && cd /home/robot/code/openvino_binart_example/build &&\
    . /opt/intel/computer_vision_sdk/bin/setupvars.sh&& cmake /opt/intel/computer_vision_sdk/deployment_tools/inference_engine/samples/ && make && cd .. &&\
    /bin/cp -rf build /opt/intel/computer_vision_sdk/deployment_tools/inference_engine/samples/ &&\
    cd /home/robot/ &&rm -rf /home/robot/code/openvino_* 

# install gpg
WORKDIR /home/robot/code
RUN git clone --depth=1 https://github.com/atenpas/gpg.git
WORKDIR /home/robot/code/gpg
RUN mkdir build
WORKDIR /home/robot/code/gpg/build
RUN cmake .. && make && make install
RUN ldconfig

# install librealsense
#WORKDIR /home/robot/code
#RUN apt-get update && apt-get install -y git \
#      libssl-dev \
#      libusb-1.0-0-dev \
#      pkg-config \
#      libgtk-3-dev \
#      libglfw3-dev &&\
#    rm -rf /var/lib/apt/lists/* &&\
#    git clone --depth=1 https://github.com/IntelRealSense/librealsense.git -b v2.17.1 &&\
#    cd librealsense && mkdir -p build && cd build &&\
#    cmake ../ -DBUILD_EXAMPLES=true &&\
#    make uninstall && make clean && make -j8 && make install &&\
#    mkdir -p /etc/udev/rules.d &&\
#    cd ../ && cp config/99-realsense-libusb.rules /etc/udev/rules.d/ &&\
#    ldconfig

WORKDIR /root/
