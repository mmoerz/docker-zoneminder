FROM alpine:3.7

# MAINTAINER Philipp Schmitt <philipp@schmitt.co>
MAINTAINER Jason Antman <jason@jasonantman.com>

ARG version
ARG build_date

RUN echo "@edgetest http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache zoneminder mysql-client apache2 php5-apache2 php5-fpm \
        php5-pdo php5-pdo_mysql supervisor ffmpeg perl-data-uuid \
        perl-data-dump php5-ctype perl-sys-cpu@edgetest perl-log-log4perl perl-sys-meminfo \
    && apk add --no-cache --virtual build-deps make gcc musl-dev perl-dev \
       expat-dev \
    && cpan install XML::Parser::Expat Class::Std::Fast IO::Socket::Multicast \
    && cpan -f install SOAP::WSDL \
    && apk del --no-cache build-deps

COPY build /tmp/build/
RUN install -m 0755 -o root -g root /tmp/build/entrypoint.sh /entrypoint.sh \
    && install -m 0644 -o root -g root /tmp/build/apache2_zoneminder.conf /etc/apache2/conf.d/zoneminder.conf \
    && install -m 0644 -o root -g root /tmp/build/supervisord.conf /etc/supervisord.conf \
    && install -m 0755 -o root -g root /tmp/build/mysql.sh /usr/bin/zm_mysql \
    && install -m 0644 -o root -g root /tmp/build/php-fpm.conf /etc/php5/php-fpm.conf \
    && install -m 0644 -o root -g root /tmp/build/zm.conf /etc/zm.conf \
    && mkdir -p /var/lib/zoneminder /var/run/zoneminder \
    && rm -Rf /tmp/build

EXPOSE 80

ENV ZM_DB_TYPE=mysql ZM_DB_HOST=zm.db \
    ZM_DB_PORT=3306 ZM_DB_NAME=zoneminder ZM_DB_USER=zoneminder \
    ZM_DB_PASS=zoneminder

LABEL org.label-schema.build-date=$build_date org.label-schema.vcs-url="https://github.com/jantman/docker-zoneminder" org.label-schema.vcs-ref=$version org.label-schema.schema-version="1.0"

ENTRYPOINT ["/entrypoint.sh"]
