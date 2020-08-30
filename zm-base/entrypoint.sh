#!/usr/bin/env ash

# Edit config file
ZM_CONFIG=/etc/zoneminder/zm.conf
ZM_DB_TYPE=${ZM_DB_TYPE:-mysql}
ZM_DB_HOST=${ZM_DB_HOST:-zm.db}
ZM_DB_PORT=${ZM_DB_PORT:-3306}
ZM_DB_NAME=${ZM_DB_NAME:-zoneminder}
ZM_DB_USER=${ZM_DB_USER:-zoneminder}
ZM_DB_PASS=${ZM_DB_PASS:-zoneminder}
SERVERNAME=${SERVERNAME:-localhost}

WWW_USER=zoneminder
WWW_GRP=zoneminder

# if zm.conf is missing, restore all configuration files
if [ ! -f $ZM_CONFIG ] ; then
  cd / && tar -xzf /root/etc_zoneminder.tar.gz
fi

sed -i "s/\(ZM_DB_TYPE\)=.*/\1=$ZM_DB_TYPE/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_HOST\)=.*/\1=$ZM_DB_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PORT\)=.*/\1=$ZM_DB_PORT/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_NAME\)=.*/\1=$ZM_DB_NAME/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_USER\)=.*/\1=$ZM_DB_USER/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PASS\)=.*/\1=$ZM_DB_PASS/g" "$ZM_CONFIG"

# nginx is used and should be part of the frontend containers

# this is for develepment purposes, test for essential directories
TESTDIRS="/var/run/zoneminder /var/lib/zoneminder /var/log/zoneminder"
TESTDIRS="$TESTDIRS /var/lib/zoneminder/images"
TESTDIRS="$TESTDIRS /var/lib/zoneminder/events"
TESTDIRS="$TESTDIRS /usr/share/zoneminder-webui/htdocs/images"
TESTDIRS="$TESTDIRS /usr/share/zoneminder-webui/htdocs/events"

for Dir in $TESTDIRS ; do
  [ ! -d /var/run/zoneminder ] && echo "WARNING: $Dir is missing"
done

#install -d -o $WWW_USER -g $WWW_GRP /var/run/zoneminder
#chown -R $WWW_USER:$WWW_GRP  "$ZM_CONFIG" /var/lib/zoneminder/* /var/run/zoneminder
#chown -R $WWW_USER:wheel /var/log/zoneminder
#mkdir /run/apache2 && chown apache:apache /run/apache2

#
# Ugg, Ugg, I need cleanup>
# remove the stuff that might be left behind by misbehaving daemons
#
rm -f /var/run/zoneminder/zmaudit.pid

# Wait for DB server to come up
# TODO
if ! mysqladmin --wait=30 -P "$ZM_DB_PORT" -u "$ZM_DB_USER" --password="$ZM_DB_PASS" -h "$ZM_DB_HOST" ping
then
    echo "Could not reach MySQL server in time... Abort." >&2
    exit 3
fi

# Init DB
DB_INITALIZED="$(mysql -u $ZM_DB_USER --password=$ZM_DB_PASS -h $ZM_DB_HOST $ZM_DB_NAME -e 'show tables;')"
if [[ -z "$DB_INITALIZED" ]]
then
    echo -n "Database has not been initialized... "
    sed -i 's/`zm`/'"$ZM_DB_NAME"'/g' /usr/share/zoneminder/db/zm_create.sql
    # /etc/init.d/zoneminder setup
    mysql -u "$ZM_DB_USER" -p"$ZM_DB_PASS" -h "$ZM_DB_HOST" -P "$ZM_DB_PORT" < "/usr/share/zoneminder/db/zm_create.sql" || exit 1
    echo 'Done!'
fi

# Start server
exec supervisord
#/bin/bash
