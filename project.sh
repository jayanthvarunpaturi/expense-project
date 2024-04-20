#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2...FAILURE"
        exit 1
    else 
        echo "$2...SUCCESS"
    fi
}


if [ $USERID -ne 0 ]
then 
    echo "Please run this script with root access."
    exit 1
else
    echo "You are super user."
fi


for i in $@
do  
  echo "package to install:$i"
  dnf list installed $i &>>$LOGFILE
  if [ $? -eq 0 ]
  then
      echo -e "$i already installed....$R Skipped $N"
  else
      dnf install $i -y &>>$LOGFILE
      VALIDATE $? "Installation of $i"
  fi

done



dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL Server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"

mysql -h db.daws78s.online -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi
