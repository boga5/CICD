#!/bin/bash
source .env
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
###############################################
image_status=`docker images -a | grep "$robot_image_name"`

if [ ! -z "$image_status" ];
then
  docker rmi -f $robot_image_name
fi
###############################################
image_status=`docker images -a | grep "${Docker_Reg_Name}/${om_image_name}"`

if [ ! -z "$image_status" ];
then
  docker rmi -f ${Docker_Reg_Name}/${om_image_name}
  docker rmi -f ${Docker_Reg_Name}/${om_image_name}:10
fi
###############################################
image_status=`docker images -a | grep "${Docker_Reg_Name}/${cp_image_name}"`

if [ ! -z "$image_status" ];
then
  docker rmi -f ${Docker_Reg_Name}/${cp_image_name}
  docker rmi -f ${Docker_Reg_Name}/${cp_image_name}:10
fi

echo "Removed all containers"
