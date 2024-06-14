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


useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding application User"

mkdir /app &>> $LOGFILE
VALIDATE $? "setup an app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Download the application code to created app directory."

cd /app
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping catalogue"

npm install 
VALIDATE $? "download the dependencies"

#cp catalogue.service /etc/systemd/system/catalogue.service

#use absolute path, bcz catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying Catalogue Service"

systemctl daemon-reload
VALIDATE $? "Load the service."

systemctl enable catalogue
VALIDATE $? "enable the service."

systemctl start catalogue
VALIDATE $? "Start the catalogue service."

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo."

dnf install mongodb-org-shell -y
VALIDATE $? "install mongodb-client."

mongo --host $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "Load Schema--Loading catalogue data into MongoDB"
