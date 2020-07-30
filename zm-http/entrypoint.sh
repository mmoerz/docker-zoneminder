#!/usr/bin/env ash

WWW_USER=nginx
WWW_GROUP=www
WWW_PERMS=$WWW_USER:$WWW_GROUP

# Edit config file
ZM_CONFIG=/etc/zm.conf
ZM_DB_TYPE=${ZM_DB_TYPE:-mysql}
ZM_DB_HOST=${ZM_DB_HOST:-zm.db}
ZM_DB_PORT=${ZM_DB_PORT:-3306}
ZM_DB_NAME=${ZM_DB_NAME:-zoneminder}
ZM_DB_USER=${ZM_DB_USER:-zoneminder}
ZM_DB_PASS=${ZM_DB_PASS:-zoneminder}

NGINX_CONFIG=/etc/nginx/conf.d/zoneminder.conf
SERVERNAME=${SERVERNAME:-localhost}

sed -i "s/\(ZM_DB_TYPE\)=.*/\1=$ZM_DB_TYPE/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_HOST\)=.*/\1=$ZM_DB_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PORT\)=.*/\1=$ZM_DB_PORT/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_NAME\)=.*/\1=$ZM_DB_NAME/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_USER\)=.*/\1=$ZM_DB_USER/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PASS\)=.*/\1=$ZM_DB_PASS/g" "$ZM_CONFIG"

sed -i "s/server_name\s*\(.*\)/\1=$SERVERNAME/" "$NGINX_CONFIG"

# fixes that should be unecessary once a correcte zoneminder.apk is used>
DIRS="/var/run/zoneminder /var/lib/zoneminder /var/lib/zoneminder/events"
DIRS="$DIRS /var/lib/zoneminder/images /var/cache/zoneminder"
DIRS="$DIRS /usr/share/webapps/zoneminder/htdocs/images"
DIRS="$DIRS /usr/share/webapps/zoneminder/htdocs/events"
for DIR in $DIRS; do
  [ ! -d $DIR ] && mkdir -p $DIR
  chown -R $WWW_PERMS $DIR
done

chown -R nginx:www-data "$ZM_CONFIG" /var/run/zoneminder
chown -R nginx:wheel /var/log/zoneminder
# [ ! -d "/run/apache2" ] && mkdir /run/apache2 && chown nginx:nginx /run/nginx

# Wait for DB server to come up
# TODO
if ! mysqladmin --wait=30 -P "$ZM_DB_PORT" -u "$ZM_DB_USER" --password="$ZM_DB_PASS" -h "$ZM_DB_HOST" ping
then
    echo "Could not reach MySQL server in time... Abort." >&2
    exit 3
fi

exec /usr/sbin/httpd -DFOREGROUND -k start 
