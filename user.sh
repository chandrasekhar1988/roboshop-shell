#!/bin/bash
ID=$(id -u)

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
MONGODB_HOST=mongodb.chone.online
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
if [ $1 -ne 0 ] 
then
echo -e "ERROR: $2..... ${RED} is failed ${ENDCOLOR}"
exit 1  
else
echo -e "$2..... ${GREEN} is success ${ENDCOLOR}"
fi
}

if [ $ID -ne 0 ] 
then
echo "ERROR: Please run this script with root access"
exit 1
else
echo "you are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current nodejs"


dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ] 
then
useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding application User"
exit 1
else
echo "useradd already exists...."
fi


#-p means, if app directory exists--ok, else create
mkdir -p /app &>> $LOGFILE
VALIDATE $? "setup an app directory"


curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
VALIDATE $? "Download the application code to created app directory."

cd /app
#overwrite , if any data exists
unzip -o /tmp/user.zip
VALIDATE $? "unzipping user"

npm install 
VALIDATE $? "download the dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service
VALIDATE $? "copying user Service"

systemctl daemon-reload
VALIDATE $? "Load the service."

systemctl enable user
VALIDATE $? "enable the service."

systemctl start user
VALIDATE $? "Start the catalogue service."

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo."

dnf install mongodb-org-shell -y
VALIDATE $? "install mongodb-client."

mongo --host $MONGODB_HOST </app/schema/user.js
VALIDATE $? "Load Schema--Loading user data into MongoDB"