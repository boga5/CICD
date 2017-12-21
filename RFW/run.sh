#!/bin/bash
#while ! nc -z cpservice 8080;
#        do
 #         echo sleeping;
 #         sleep 5;
  #      done;
 #       echo connected;
#sh /robot/robot.sh cpserver 8080 cicd_sample/cicd_sample@52.67.80.187:1521/GGKF
#!/bin/bash
count=0
while [[ ! nc -z cpservice 8080 ] -a [ $count -le 180 ]];
        do
          echo sleeping;
          sleep 5;
          count=`expr $count + 1`
        done;
        echo "connected Sneha"
if [ $count -le 180 ]; then
        sh /robot/robot.sh cpserver 8080 cicd_sample/cicd_sample@52.67.80.187:1521/GGKF
else
        exit 1
fi
#while true
#do
#	echo "Press [CTRL+C] to stop.."
#	sleep 1
#done 


