FROM zm-base:0.1

#MAINTAINER Philipp Schmitt <philipp@schmitt.co>
#MAINTAINER Jason Antman <jason@jasonantman.com>
MAINTAINER Michael Moerz <michael@moerz.co.at>
VOLUME [ "/etc/zoneminder", "/var/log/zoneminder" ]

ARG version
ARG build_date

RUN cd /etc/apk/keys/ && wget http://natoka.de/alpine/mmoerz.rsa.pub \
    && echo "@mmoerz http://natoka.de/alpine/packages/mmoerz/" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
        nginx \ 
        mariadb-client \
        zoneminder-cgi@mmoerz \
        zoneminder-webui@mmoerz \
        zoneminder-webui-nginx@mmoerz \
        php7-fpm php7-pdo php7-pdo_mysql php7-ctype 
# perl package that fixes a missing dep in the 1.32.5 zoneminder package

COPY resources /root/build/

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /root/build/install.sh /entrypoint.sh
RUN /root/build/install.sh

EXPOSE 9000

ENV ZM_DB_TYPE=mysql ZM_DB_HOST=zm.db \
    ZM_DB_PORT=3306 ZM_DB_NAME=zoneminder ZM_DB_USER=zoneminder \
    ZM_DB_PASS=zoneminder

LABEL org.label-schema.build-date=$build_date org.label-schema.vcs-url="https://github.com/mmoerz/docker-zm-fpm" org.label-schema.vcs-ref=$version org.label-schema.schema-version="1.0"

ENTRYPOINT ["/entrypoint.sh"]
#ENTRYPOINT ["/bin/bash"]

