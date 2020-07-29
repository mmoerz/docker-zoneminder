#!/usr/bin/env ash

# Edit config file
ZM_CONFIG=/etc/zm.conf
ZM_DB_TYPE=${ZM_DB_TYPE:-mysql}
ZM_DB_HOST=${ZM_DB_HOST:-zm.db}
ZM_DB_PORT=${ZM_DB_PORT:-3306}
ZM_DB_NAME=${ZM_DB_NAME:-zoneminder}
ZM_DB_USER=${ZM_DB_USER:-zoneminder}
ZM_DB_PASS=${ZM_DB_PASS:-zoneminder}
SERVERNAME=${SERVERNAME:-localhost}

sed -i "s/\(ZM_DB_TYPE\)=.*/\1=$ZM_DB_TYPE/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_HOST\)=.*/\1=$ZM_DB_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PORT\)=.*/\1=$ZM_DB_PORT/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_NAME\)=.*/\1=$ZM_DB_NAME/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_USER\)=.*/\1=$ZM_DB_USER/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PASS\)=.*/\1=$ZM_DB_PASS/g" "$ZM_CONFIG"

echo "ServerName $SERVERNAME" > /etc/apache2/conf.d/0_servername.conf
install -d -o apache -g apache /var/run/zoneminder
install -d -o apache -g apache /var/lib/zoneminder
install -d -o apache -g apache /usr/share/webapps/zoneminder/htdocs/images
install -d -o apache -g apache /usr/share/webapps/zoneminder/htdocs/events
chown -R apache:apache "$ZM_CONFIG" /var/lib/zoneminder/* /var/run/zoneminder
chown -R apache:wheel /var/log/zoneminder
mkdir /run/apache2 && chown apache:apache /run/apache2

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
