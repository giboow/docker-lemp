#!/bin/bash

StartMySQL ()
{
    /usr/bin/mysqld_safe > /dev/null 2>&1 &
    # Time out in 1 minute
    LOOP_LIMIT=13
    for (( i=0 ; ; i++ )); do
        if [ ${i} -eq ${LOOP_LIMIT} ]; then
            echo "Time out. Error log is shown as below:"
            tail -n 100 ${LOG}
            exit 1
        fi
        echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1 && break
    done
}

StartMySQL
mysql -uroot -e "CREATE USER 'hotplex'@'%' IDENTIFIED BY 'hotplex'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'hotplex'@'%' WITH GRANT OPTION"
mysql -uroot -e "CREATE DATABASE hotplex"

#start services
service php5-fpm start
service nginx start

