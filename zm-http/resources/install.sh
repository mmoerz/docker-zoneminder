#!/usr/bin/env ash

res=/root/build

#install -m 0644 -o root -g root $res/php-timezone.ini /etc/php7/conf.d/timezone.ini
#install -m 0644 -o root -g root $res/php-fpm.conf /etc/php7/php-fpm.conf 
install -m 0644 -o root -g root $res/nginx_pid.conf /etc/nginx/modules/pid.conf
install -m 0644 -o root -g root $res/nginx_zm.conf /etc/nginx/conf.d/zoneminder.conf 
rm -rf $res


