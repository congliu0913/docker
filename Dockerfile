# install openvine_2019_R1
# install ros2 
# install opencv 3.4.2
from congliu0913/ros2:openvino_2019_R1

MAINTAINER Cong Liu congx.liu@intel.com

SHELL ["/bin/bash", "-c"]

ARG http_proxy
# install opencv
WORKDIR /home/robot/code
RUN git clone https://github.com/opencv/opencv
RUN git clone https://github.com/opencv/opencv_contrib
WORKDIR /home/robot/code/opencv
RUN git checkout 3.4.2 && cd ../opencv_contrib/ && git checkout 3.4.2
RUN mkdir build && cd build
WORKDIR /home/robot/code/opencv/build
RUN cmake -DOPENCV_EXTRA_MODULES_PATH=/home/robot/code/opencv_contrib/modules -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_opencv_cnn_3dobj=OFF ..
RUN make -j12
RUN make install
RUN ldconfig
#RUN cd /usr/lib/x86_64-linux-gnu &&  ln -s libboost_python-py36.so libboost_python3.so
RUN apt-get install  -y libudev-dev \
         pkg-config \
         libgtk-3-dev \
         libglfw3-dev  \
         libusb-1.0
