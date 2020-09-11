#!/usr/bin/env ash

WWW_USER=nginx
WWW_GROUP=nginx
WWW_PERMS=$WWW_USER:$WWW_GROUP

# Edit config file
ZM_CONFIG_DIR=/etc/zoneminder
ZM_CONFIG=$ZM_CONFIG_DIR/zm.conf
ZM_DB_TYPE=${ZM_DB_TYPE:-mysql}
ZM_DB_HOST=${ZM_DB_HOST:-zm.db}
ZM_DB_PORT=${ZM_DB_PORT:-3306}
ZM_DB_NAME=${ZM_DB_NAME:-zoneminder}
ZM_DB_USER=${ZM_DB_USER:-zoneminder}
ZM_DB_PASS=${ZM_DB_PASS:-zoneminder}

NGINX_CONFIG=/etc/nginx/nginx.conf
NGINX_ZM_CONFIG=/etc/nginx/conf.d/zoneminder.conf
NGINX_WORKER=${NGINX_WORKER:-1}
SERVERNAME=${SERVERNAME:-localhost}

# if zm.conf is missing, restore all configuration files
if [ ! -f $ZM_CONFIG ] ; then
  cd / && tar -xzf /root/etc_zoneminder.tar.gz
fi
# fix permissions - a common error when rebuilding the docker image
# uids and gids may change - and files become inaccessible
chown -R zoneminder:zoneminder $ZM_CONFIG_DIR

sed -i "s/\(ZM_DB_TYPE\)=.*/\1=$ZM_DB_TYPE/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_HOST\)=.*/\1=$ZM_DB_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PORT\)=.*/\1=$ZM_DB_PORT/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_NAME\)=.*/\1=$ZM_DB_NAME/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_USER\)=.*/\1=$ZM_DB_USER/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PASS\)=.*/\1=$ZM_DB_PASS/g" "$ZM_CONFIG"

sed -i "s/\(worker_processes\s\+\).*/\1$NGINX_WORKER;/" "$NGINX_CONFIG"
sed -i "s/\(server_name\s\+\).*/\1$SERVERNAME;/" "$NGINX_ZM_CONFIG"

# this is for develepment purposes, test for essential directories
TESTDIRS="/var/run/zoneminder /var/lib/zoneminder /var/log/zoneminder"
TESTDIRS="$TESTDIRS /var/lib/zoneminder/images"
TESTDIRS="$TESTDIRS /var/lib/zoneminder/events"
TESTDIRS="$TESTDIRS /usr/share/zoneminder-webui/htdocs/images"
TESTDIRS="$TESTDIRS /usr/share/zoneminder-webui/htdocs/events"

for Dir in $TESTDIRS ; do
  [ ! -d /var/run/zoneminder ] && echo "WARNING: $Dir is missing"
done

# fixes that should be unecessary once a correcte zoneminder.apk is used>
#DIRS="/var/run/zoneminder /var/lib/zoneminder /var/lib/zoneminder/events"
#DIRS="$DIRS /var/lib/zoneminder/images /var/cache/zoneminder"
#DIRS="$DIRS /usr/share/zoneminder-webui/htdocs/images"
#DIRS="$DIRS /usr/share/zoneminder-webui/htdocs/events"
# TODO: move this into the .apk
DIRS=/var/cache/zoneminder
for DIR in $DIRS; do
  [ ! -d $DIR ] && mkdir -p $DIR
  chown $WWW_PERMS $DIR
done


chown -R nginx:nginx /var/run/zoneminder
#chown -R nginx:wheel /var/log/zoneminder
# [ ! -d "/run/apache2" ] && mkdir /run/apache2 && chown nginx:nginx /run/nginx

# Wait for DB server to come up
# TODO
if ! mysqladmin --wait=30 -P "$ZM_DB_PORT" -u "$ZM_DB_USER" --password="$ZM_DB_PASS" -h "$ZM_DB_HOST" ping
then
    echo "Could not reach MySQL server in time... Abort." >&2
    exit 3
fi

exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
