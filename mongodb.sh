#!/bin/bash
ID=$(id -u)

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongoDB Repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing mongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enableing mongoDB"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mongoDB"

#Using SED editor,we are updating value
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "remote access to mongoDB"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting mongoDB"



