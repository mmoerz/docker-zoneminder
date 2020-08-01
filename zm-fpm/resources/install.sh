#!/usr/bin/env ash

res=/root/build

mkdir -p /etc/php7/conf.d

install -m 0644 -o root -g root $res/php-timezone.ini /etc/php7/conf.d/timezone.ini
install -m 0644 -o root -g root $res/php-fpm.conf /etc/php7/php-fpm.conf 
install -m 0755 -o root -g root $res/mysql.sh /usr/bin/zm_mysql 
rm -rf $res

