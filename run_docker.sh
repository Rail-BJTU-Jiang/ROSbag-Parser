# a bash file that will launch a docker container, do volumn mapping, do network mapping, do x11 forwarding, make gpu visible to the container, and run the container with the specified image

# usage: ./run_docker.sh <image_name> <label>


# check if the user has provided the image name
if [ -z "$1" ]
then
    echo "Please provide the image name"
    exit 1
fi

# check if the user has provided the label, otherwise use latest
if [ -z "$2" ]
then
    label="latest"
else
    label=$2
fi

# check if the user has provided the container name, otherwise use the image name
container_name=$1

# volumn mapping
volumes="-v /home/$USER:/home/$USER -v /media:/media"
# gpu setting
gpu="--gpus all"
# network mapping
network="--network host"
# x11
x11="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix"

# run the container
docker run -itd --rm --name $container_name $volumes $gpu $network $x11 $1:$label
