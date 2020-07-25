#!/usr/bin/env ash

install -m 0644 -o root -g root /tmp/build/apache2_zoneminder.conf /etc/apache2/conf.d/zoneminder.conf 
install -m 0644 -o root -g root /tmp/build/supervisord.conf /etc/supervisord.conf 
install -m 0755 -o root -g root /tmp/build/mysql.sh /usr/bin/zm_mysql 
install -m 0644 -o root -g root /tmp/build/php-fpm.conf /etc/php7/php-fpm.conf 
install -m 0644 -o root -g root /tmp/build/zm.conf /etc/zm.conf 
install -m 0644 -o root -g root /tmp/build/amcrest841.pm /usr/share/perl5/vendor_perl/ZoneMinder/Control/amcrest841.pm 
mkdir -p /var/lib/zoneminder /var/run/zoneminder 
rm -Rf /tmp/build

