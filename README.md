# ROSbag-Parser
Parsing ROS Bag file.

## How-To
You have to run `parse_rosbag.py` in a ROS environment.

For example, if you have already installed ROS on your host machine, you can simply run in a shell
```bash
source /opt/ros/noetic/setup.sh
python3 parse_rosbag.py xxxxx.bag
```

Otherwise, you can use ROS docker image:
```
docker pull osrf/ros:noetic-desktop-full
bash run_docker.sh osrf/ros noetic-desktop-full
docker ps
# find out the container id
docker exec -it container_id /bin/bash
source /opt/ros/noetic/setup.sh
python3 parse_rosbag.py xxxxx.bag
```

## Customize
```python
for topic, msg, t in bag.read_messages(topics=["/camera/color/image_raw", "/livox/lidar"]):
        if topic == "/camera/color/image_raw":
            # rospy.loginfo("image: {}".format(t.to_sec()))
            # rospy.loginfo("image msg: {}".format(msg.header.stamp.to_sec()))
            # rospy.loginfo("image frame_id: {}".format(msg.header.seq))
            save_image(msg, folder, img_count)
            # imgtimestamps.append(msg.header.stamp.to_sec())
            imgtimestamps.append(t.to_sec())
            img_count+=1
        elif topic == "/livox/lidar":
            # rospy.loginfo("lidar: {}".format(t.to_sec()))
            # rospy.loginfo("lidar msg: {}".format(msg.header.stamp.to_sec()))
            # rospy.loginfo("lidar frame_id: {}".format(msg.header.seq))
            save_pcd(msg, folder, lidar_count)
            # lidartimestamps.append(msg.header.stamp.to_sec())
            lidartimestamps.append(t.to_sec())
            lidar_count+=1
```
change the topics listed here according to your needs.


# matlab calibration parameters exporter to opencv yaml file
Each time after the calibration and exporting the parameters to the Matlab workspace, run `export_stereo_to_yaml(stereoParams)` or `export_to_yaml(cameraParams)` to generate a yaml file called `calibration.yaml` that contains the calibration results and can be directly loaded by opencv.
