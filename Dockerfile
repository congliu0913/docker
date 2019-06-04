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
#RUN apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE &&\
RUN if [ "$http_proxy" != "" ]; \
    then \
      apt-key adv --keyserver keys.gnupg.net \
      --keyserver-options http-proxy=$http_proxy \
      --recv-key C8B3A55A6F3EFCDE ;\
    else \
      apt-key adv --keyserver keys.gnupg.net \
      --recv-key C8B3A55A6F3EFCDE ;\
    fi
RUN apt-get update && apt-get install -y python3-software-properties software-properties-common &&\
       rm -rf /var/lib/apt/lists/*
RUN add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main" -u &&\
    apt-get update && apt-get install -y librealsense2-dkms \
      librealsense2-utils \
      librealsense2-dev \
      librealsense2-dbg &&\
       rm -rf /var/lib/apt/lists/*

# move moveit code
RUN apt-get update && apt-get install -y ros-melodic-ros-controllers ros-melodic-ros-control &&\
      rm -rf /var/lib/apt/lists/* 
USER robot
ARG http_proxy
WORKDIR /home/robot
RUN mkdir -p ws_moveit/src
WORKDIR /home/robot/ws_moveit
RUN wstool init src &&\
    wstool merge -t src https://raw.githubusercontent.com/ros-planning/moveit/master/moveit.rosinstall &&\
    wstool update -t src
RUN number=`sed -n '/if (callIK(ik_query, adapted_ik_validity_callback, ik_timeout_, state, project && a == 0))/=' src/moveit/moveit_core/constraint_samplers/src/default_constraint_samplers.cpp` &&\
    echo $number &&\
    sed -i "${number}a\    if (callIK(ik_query, adapted_ik_validity_callback, ik_timeout_, state, project || a == 0))" src/moveit/moveit_core/constraint_samplers/src/default_constraint_samplers.cpp && \
    sed -i "${number}d" src/moveit/moveit_core/constraint_samplers/src/default_constraint_samplers.cpp

# build
WORKDIR /home/robot/ws_moveit/src
RUN git clone --depth=1 https://github.com/sharronliu/gpd -b libgpd
RUN git clone --depth=1 https://github.com/ros-industrial/universal_robot.git
RUN git clone --depth=1 https://github.com/ros-industrial/ur_modern_driver.git -b kinetic-devel
RUN git clone --depth=1 https://github.com/ros-industrial/industrial_core.git -b kinetic-devel 
WORKDIR /home/robot/ws_moveit
RUN ls src/ &&rm devel install build logs -rf
RUN catkin config --extend /opt/ros/melodic --cmake-args -DCMAKE_BUILD_TYPE=Release -DUSE_OPENVINO=ON -DBUILD_RANDOM_PICK=ON -DUSE_CAFFE=OFF &&\
    source /opt/intel/computer_vision_sdk/bin/setupvars.sh && export OpenCV_DIR=/usr/share/OpenCV &&catkin build
WORKDIR /home/robot/ws_moveit
