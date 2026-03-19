#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.109v.store

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script wiht root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx
VALIDATE $? "Starting and enabling nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOGS_FILE
VALIDATE $? "Removing existing code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading frontend Code"

cd /usr/share/nginx/html
VALIDATE $? "Moving to nginx directory" 

unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unzip frontend code"

rm -rf /etc/nginx/nginx.conf  &>>$LOGS_FILE
VALIDATE $? "Removing existing code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Restarted nginx"



