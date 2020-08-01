#!/usr/bin/env ash

res=/root/build

install -m 0644 -o root -g root $res/php-timezone.ini /etc/php7/conf.d/timezone.ini
#install -m 0644 -o root -g root $res/apache2_zoneminder.conf /etc/apache2/conf.d/zoneminder.conf 
install -m 0644 -o root -g root $res/nginx_pid.conf /etc/nginx/modules/pid.conf
install -m 0644 -o root -g root $res/nginx_zm.conf /etc/nginx/conf.d/zoneminder.conf 
install -m 0755 -o root -g root $res/mysql.sh /usr/bin/zm_mysql 
install -m 0644 -o root -g root $res/php-fpm.conf /etc/php7/php-fpm.conf 
rm -rf $res


