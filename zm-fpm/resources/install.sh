#!/usr/bin/env ash

res=/root/build

mkdir -p /etc/php7/conf.d

install -m 0644 -o root -g root $res/php-timezone.ini /etc/php7/conf.d/timezone.ini
install -m 0644 -o root -g root $res/php-fpm.conf /etc/php7/php-fpm.conf 
rm -rf $res

