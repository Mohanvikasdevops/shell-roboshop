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

dnf install golang -y &>>$LOGS_FILE
VALIDATE $? "Installing golang"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then   
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist .... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creatng app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading dispatch Code"

cd /app
VALIDATE $? "Moving to app directory" 

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Removing existing code"

unzip /tmp/dispatch.zip &>>$LOGS_FILE
VALIDATE $? "Unzip dispatch code"

cd /app 
cd /app 
go mod init dispatch
go get 
go build &>>$LOGS_FILE
VALIDATE $? "Installing dependecies"

cp $SCRIPT_DIR/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGS_FILE
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable dispatch &>>$LOGS_FILE
systemctl start dispatch
VALIDATE $? "Starting and enabling dispatch"