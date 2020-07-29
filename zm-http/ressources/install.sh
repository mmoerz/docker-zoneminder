#!/usr/bin/env ash

res=/root/build

install -m 0644 -o root -g root $res/php-timezone.ini /etc/php7/conf.d/timezone.ini
install -m 0644 -o root -g root $res/apache2_zoneminder.conf /etc/apache2/conf.d/zoneminder.conf 
install -m 0755 -o root -g root $res/mysql.sh /usr/bin/zm_mysql 
install -m 0644 -o root -g root $res/php-fpm.conf /etc/php7/php-fpm.conf 
rm -rf $res

# fixes that should be unecessary once a correcte zoneminder.apk is used>
mkdir -p /var/lib/zoneminder/events
mkdir -p /var/lib/zoneminder/images
mkdir -p /var/run/zoneminder
mkdir -p /var/cache/zoneminder
chown apache:www-data /var/lib/zoneminder/events
chown apache:www-data /var/lib/zoneminder/images
chown apache:www-data /var/cache/zoneminder
