FROM ubuntu:14.04

MAINTAINER Philippe Gibert <philippe.gibert@gmail.com>

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y python-software-properties\
                       software-properties-common\
                       curl\
                       aptitude

#install and config of php-fpm 5.6
RUN add-apt-repository ppa:ondrej/php5-5.6
RUN apt-get update
RUN apt-get install -y --force-yes php5-fpm\
                                   php5-mysql\
                                   php5-cli\
                                   php5-mcrypt\
                                   php5-dev\
                                   php-apc\
                                   php-pear\
                                   php5-xdebug

RUN apt-get install -y --force-yes php5-curl
RUN apt-get install -y --force-yes nginx
RUN apt-get install -y --force-yes mysql-server-5.6

#set timezone
RUN echo "Europe/Paris" > /etc/timezone
RUN sed -i "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php5/cli/php.ini

#init php
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

# init nginx
RUN echo "daemon on;" >> /etc/nginx/nginx.conf
ADD build/nginx/default   /etc/nginx/sites-available/default
EXPOSE 80

#install mysql
RUN sed -i "s/skip-external-locking/#skip-external-locking/" /etc/mysql/my.cnf
RUN sed -i "s/bind-address/\#bind-address/" /etc/mysql/my.cnf
EXPOSE 3306


RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD build/init.sh /init.sh
RUN chmod +x /init.sh

# docker run, /bin/bash is for keep running the container
ENTRYPOINT  /init.sh &&\
            /bin/bash
