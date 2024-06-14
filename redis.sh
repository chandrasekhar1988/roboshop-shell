#!/bin/bash
ID=$(id -u)

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
MONGODB_HOST=mongodb.chone.online
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
VALIDATE $? "Disabling current nodejs"

dnf module enable redis:remi-6.2 -y
VALIDATE $? "Enable Redis 6.2 from package streams"


dnf install redis -y
VALIDATE $? "Install Redis"

#Using SED editor,we are updating value 
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "remote access to redis"

systemctl enable redis
VALIDATE $? "enable the service."

systemctl start redis
VALIDATE $? "Start the redis service."