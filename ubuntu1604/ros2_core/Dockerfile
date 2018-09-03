FROM otc-rse/ubuntu1604:ros2_core_V3
MAINTAINER Liu Cong "congx.liu@intel.com"
ENV http_proxy http://child-prc.intel.com:913
ENV https_proxy http://child-prc.intel.com:913
ENV ftp_proxy ftp://child-prc.intel.com:913
ADD sudoers /etc/sudoers
RUN apt-get update
RUN apt-get upgrade -y 
RUN apt-get install -y libxaw7-dev 	libgles2-mesa-dev 	libglu1-mesa-dev 	qt5-default 	libyaml-cpp-dev 	libcurl4-openssl-dev 	libpcl-dev 	lsb-release 	python3-catkin-pkg-modules 	libassimp-dev 	libpoco-dev 	python3-colcon-common-extensions
RUN python3 -m pip install pytest-repeat pytest-rerunfailures
WORKDIR /tmp/
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
RUN git clone https://github.com/movidius/ncsdk
RUN git clone https://github.com/movidius/ncappzoo
RUN lsb_release -a
RUN ls
ADD pip.conf /root/.pip/pip.conf
ADD pip.conf /home/robot/.pip/pip.conf
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
RUN cd librealsense && git checkout v2.9.1 && git branch -a
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
