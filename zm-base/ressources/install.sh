#!/usr/bin/env ash

res=/root/build
zmconfd=/etc/zoneminder/conf.d

install -m 0644 -o root -g root $res/supervisord.conf /etc/supervisord.conf 
install -m 0755 -o root -g root $res/mysql.sh /usr/bin/zm_mysql 
install -m 0644 -o root -g root $res/03-web.conf $zmconfd/03-web.conf
#install -m 0644 -o root -g root -d $res/zoneminder/conf.d
#install -m 0644 -o root -g root /tmp/build/amcrest841.pm /usr/share/perl5/vendor_perl/ZoneMinder/Control/amcrest841.pm 
rm -rf $res

# add missing directories (for now)
install -m 0644 -o root -g root -d /usr/share/zoneminder-webui/htdocs

