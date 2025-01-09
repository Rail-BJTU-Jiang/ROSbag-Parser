# write a python script that parse a ros bag file and extract the images, the pcd files and the timestamps
# the script should save the images and the pcd files in a folder with the same name as the bag file
# the script should also save the timestamps in a txt file
# the script should be able to parse the following topics:
# /camera/rgb/image_raw/compressed
# /camera/depth_registered/points
# the script should be able to parse the following topics:
# /camera/rgb/image_raw/compressed
# /camera/depth_registered/points

import rosbag
import cv2
import numpy as np
import os
import sys
import sensor_msgs.point_cloud2 as pc2
import rospy
from sensor_msgs.msg import PointCloud2
from cv_bridge import CvBridge
from sensor_msgs.msg import Image

def save_image(msg, folder, count):
    # msg type is sensor_msgs/Image
    # save as png
    bridge = CvBridge()
    cv_image = bridge.imgmsg_to_cv2(msg)
    # rgb is bgr in opencv
    cv_image = cv2.cvtColor(cv_image, cv2.COLOR_BGR2RGB)
    # save msg as png file, name is 05d format
    cv2.imwrite(folder + "/" + '{:05d}'.format(count) + ".png", cv_image)

def save_pcd(msg, folder, count):
    # msg type is sensor_msgs/PointCloud2
    pc = pc2.read_points(msg)
    pc_list = []
    for p in pc:
        pc_list.append([p[0], p[1], p[2], p[3]])
    pc_np = np.array(pc_list)
    pc_np = pc_np.astype(np.float32)
    pc_np = pc_np.reshape(-1, 4)
    # save msg as txt file
    np.savetxt(folder + "/" + '{:05d}'.format(count) + ".txt", pc_np)


def save_timestamps(timestamps, folder, name = 'image'):
    with open(folder + "/{}_timestamps.txt".format(name), "w") as f:
        for t in timestamps:
            f.write(str(t) + "\n")

def extract_bag():
    if len(sys.argv) != 2:
        print("Usage: python3 parse_bag.py <bag_file>")
        sys.exit(1)
    print("parse_bag")
    rospy.init_node("parse_bag")

    bag_file = sys.argv[1]
    bag = rosbag.Bag(bag_file)
    folder = os.path.splitext(bag_file)[0]
    if not os.path.exists(folder):
        os.mkdir(folder)

    img_count = 0
    lidar_count = 0
    imgtimestamps = []
    lidartimestamps = []

    rospy.loginfo("Reading bag file: %s", bag_file)

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

    # save image and lidar timestamps as one file, two columns
    # timestamps = np.column_stack((imgtimestamps, lidartimestamps))
    save_timestamps(imgtimestamps, folder, name = 'image')
    save_timestamps(lidartimestamps, folder, name = 'lidar')

    bag.close()

def align_data():
    if len(sys.argv) != 2:
        print("Usage: python3 parse_bag.py <bag_file>")
        sys.exit(1)
    print("parse_bag")
    rospy.init_node("parse_bag")

    bag_file = sys.argv[1]
    bag = rosbag.Bag(bag_file)
    folder = os.path.splitext(bag_file)[0]
    if not os.path.exists(folder):
        os.mkdir(folder)

    # glob images and pcds
    import glob
    images = sorted(glob.glob(folder + "/*.png"))
    pcds = sorted(glob.glob(folder + "/*.txt"))

    # read timestamps
    imgtimestamps = []
    lidartimestamps = []
    with open(folder + "/image_timestamps.txt", "r") as f:
        for line in f:
            imgtimestamps.append(float(line))
    with open(folder + "/lidar_timestamps.txt", "r") as f:
        for line in f:
            lidartimestamps.append(float(line))

    # align timestamps
    # find the closest pcd timestamp for each image
    # save the aligned data in a new folder
    aligned_folder = folder + "_aligned"
    if not os.path.exists(aligned_folder):
        os.mkdir(aligned_folder)
    alignd_image_folder = aligned_folder + "/images"
    if not os.path.exists(alignd_image_folder):
        os.mkdir(alignd_image_folder)
    alignd_pcd_folder = aligned_folder + "/pcds"
    if not os.path.exists(alignd_pcd_folder):
        os.mkdir(alignd_pcd_folder)

    timediff = []
    recount = 0
    for i, img in enumerate(images):
        img_timestamp = imgtimestamps[i]
        closest_idx = np.argmin(np.abs(np.array(lidartimestamps) - img_timestamp))

        # if the time difference negative, jump to the next lidar
        if lidartimestamps[closest_idx] - img_timestamp < 0:
            closest_idx+=1
            if closest_idx >= len(lidartimestamps):
                continue

        # if the time difference is larger than 33 ms, skip
        if np.abs(lidartimestamps[closest_idx] - img_timestamp) > 0.033:
            continue

        pcd = pcds[closest_idx]

        # reorder the filename from 0 to n
        new_img = alignd_image_folder + "/" + '{:05d}'.format(recount) + ".png"
        new_pcd = alignd_pcd_folder + "/" + '{:05d}'.format(recount) + ".txt"
        recount += 1

        timediff.append(lidartimestamps[closest_idx] - img_timestamp)
        # copy the files
        os.system("cp {} {}".format(img, new_img))
        os.system("cp {} {}".format(pcd, new_pcd))

    # save the time difference
    with open(aligned_folder + "/time_diff.txt", "w") as f:
        for t in timediff:
            f.write(str(t) + "\n")



def main():
    # align_data()
    extract_bag()



#     types:       sensor_msgs/CameraInfo  [c9a58c1b0b154e0e6da7578cb991d214]
#              sensor_msgs/Image       [060021388200f6f0f447d0fcd9c64743]
#              sensor_msgs/PointCloud2 [1158d486dd51d683ce2f1be655c3c181]
# topics:      /camera/color/camera_info      2850 msgs    : sensor_msgsCameraInfo
#              /camera/color/image_raw        2850 msgs    : sensor_msgs/Image
#              /camera/depth/camera_info      2857 msgs    : sensor_msgs/CameraInfo
#              /camera/depth/image_rect_raw   2857 msgs    : sensor_msgs/Image
#              /livox/lidar                   1899 msgs    : sensor_msgs/PointCloud2


if __name__ == "__main__":
    main()