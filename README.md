# Precondition
## add docker group
```
sudo groupadd docker
sudo usermod -aG docker $USER
```
## Load docker image
If you got our docker image, please follow description to do at below.
```
sudo apt update && sudo apt install -y tar
tar -zxvf moveit_random_pick_place.tar.tgz
docker load < moveit_random_pick_place.tar
```
## OPTION:Please refer below command to verify image creating success
```
docker images

REPOSITORY                    TAG                        IMAGE ID            CREATED             SIZE
moveit/moveit_example_apps    random_pick_place          bda289d77f16        3 hours ago         6.57GB
```
# Run moveit demo
## Terminal 1: Launch MoveIt motion planning and rviz
After the project runs, there will be a pop-up x window, you need to set the operating environment first.
```
./setup_docker_display.sh

docker run -t -i --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /tmp/.docker.xauth:/tmp/.docker.xauth:rw -e XAUTHORITY=/tmp/.docker.xauth -e DISPLAY --name random_pick_place moveit/moveit_example_apps:random_pick_place bash

# su robot
$ source /home/robot/ws_moveit_app/devel/setup.bash
$ source /opt/intel/computer_vision_sdk/bin/setupvars.sh
$ roslaunch ur5_hitbot_ilc_platform_moveit_config demo.launch
```
## Terminal 2: Simulated camera output
```
docker exec -t -i random_pick_place bash

# su robot
$ source /home/robot/ws_moveit_app/devel/setup.bash
$ source /opt/intel/computer_vision_sdk/bin/setupvars.sh
$ roslaunch random_pick camera.launch sim:=true
```
## Terminal 3: Launch deep learning based grasp planning
```
docker exec -t -i random_pick_place bash

# su robot
$ source /home/robot/ws_moveit_app/devel/setup.bash
$ source /opt/intel/computer_vision_sdk/bin/setupvars.sh
$ roslaunch random_pick gpd.launch device:=0 plane_remove:=true
```
## Terminal 4: Launch pick-place demo
```
docker exec -t -i random_pick_place bash

# su robot
$ source /home/robot/ws_moveit_app/devel/setup.bash
$ source /opt/intel/computer_vision_sdk/bin/setupvars.sh
$ rosrun random_pick random_pick
```
![random_pick_place](https://github.com/congliu0913/docker/blob/moveit_openvino/random_pick_place_demo.png "random pick place")

Note: If you haven't already installed or want more information on how to use docker, please see the article here for more information:
https://docs.docker.com/install/
