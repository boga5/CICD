#!/bin/bash
source .env
sleep 10s
#################################################
Container_status=`docker ps | grep "$robot_container_name"`
#echo $Container_status
while [ -n "$Container_status" ]
do
  echo sleeping;
  sleep 5s;
  Container_status=`docker ps | grep "$robot_container_name"`
done;
#################################################
Container_status=`docker ps -a | grep "$robot_container_name"`

if [ ! -z "$Container_status" ];
then
  docker rm -f $robot_container_name
fi
##################################################
Container_status=`docker ps -a | grep "$cp_container_name"`

if [ ! -z "$Container_status" ];
then
  docker rm -f $cp_container_name
fi
##################################################
Container_status=`docker ps -a | grep "$om_container_name"`

if [ ! -z "$Container_status" ];
then
  docker rm -f $om_container_name
fi
#################################################
image_name=$(echo $robot_image_name| cut -d':' -f 1)
image_status=`docker images -a | grep "$image_name"`

if [ ! -z "$image_status" ];
then
  docker rmi -f $robot_image_name
fi
################################################
image_name=$(echo $cp_image_name| cut -d':' -f 1)
image_status=`docker images -a | grep "$image_name"`

if [ ! -z "$image_status" ];
then
  docker rmi -f $cp_image_name
 # docker rmi -f swamykonanki/$cp_image_name
fi
###############################################
image_name=$(echo $om_image_name| cut -d':' -f 1)
image_status=`docker images -a | grep "$image_name"`

if [ ! -z "$image_status" ];
then
  #docker rmi -f swamykonanki/$om_image_name
  docker rmi -f $om_image_name
fi
###############################################
ImageName=$(echo $cp_image_name| cut -d':' -f 1)
echo $ImageName

image_status=`docker images -a | grep "$ImageName"`

if [ ! -z "$image_status" ];
then
  docker rmi -f $ImageName
fi
###############################################
ImageName=$(echo $om_image_name| cut -d':' -f 1)
echo $ImageName

image_status=`docker images -a | grep "$ImageName"`

if [ ! -z "$image_status" ];
then
  docker rmi -f $ImageName
fi

echo "Removed all containers"
