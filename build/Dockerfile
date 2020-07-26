FROM alpine:3.12

# MAINTAINER Philipp Schmitt <philipp@schmitt.co>
#MAINTAINER Jason Antman <jason@jasonantman.com>
MAINTAINER Michael Moerz <michael@moerz.co.at>

ARG version
ARG build_date

RUN echo "@edgetest http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
 alpine-sdk perl-dev perl-utils git-perl perl-git perl-error perl libbz2 \
 bzip2-dev gzip zip lftp \
 libjpeg-turbo-dev curl-dev openssl-dbg mariadb-dev \
 ffmpeg-dev x264-dev pcre-dev libgcrypt-dev vlc-dev libvncserver-dev \
 libexecinfo-dev
#
# mysql-client \
#        apache2 php7-apache2 php7-fpm \
#        php7-pdo php7-pdo_mysql supervisor perl-data-uuid \
#        perl-data-dump php7-ctype perl-log-log4perl \
#	      perl-sys-meminfo perl-moose perl-cgi \
#        libxml2-dev \
#        perl-term-readkey perl-json perl-appconfig perl-template-toolkit \
#        perl-common-sense perl-xml-twig perl-xml-xpath perl-xml-sax \
#        perl-xml-sax-base perl-xml-namespacesupport perl-path-tiny \
#        perl-ffi-checklib perl-file-chdir perl-term-size@edgetest perl-xml-parser \
#        perl-alien-libxml2 perl-devel-hide perl-mime-charset \
#        perl-doc \
#        perl-test2-suite perl-test-warn perl-test-pod perl-test-mockobject \
#        perl-test-class perl-test-leaktrace \
#    && apk add --no-cache --virtual build-deps \
# make gcc musl-dev perl-dev expat-dev \
#    && cpan install Class::Std::F+ast IO::Socket::Multicast \
#    && cpan -f install SOAP::WSDL \
# perl-test-pod-content perl-xml-libxml perl-cgi perl-test-mockobject
# perl-test-warn perl-moose perl-test-cpan-meta perl-io-stringy perl-test-xml perl-test-class

#    && apk add --no-cache --virtual zm-build-deps \
#    && apk del --no-cache build-deps zm-build-deps

#COPY ressources /root/build/
RUN adduser -D builder
RUN addgroup builder abuild

COPY --chown=builder:builder apks/ /home/builder/

#COPY --chown=builder:builder perl-class-std /home/builder/perl-class-std/
#COPY --chown=builder:builder perl-class-std-fast /home/builder/perl-class-std-fast/
#COPY --chown=builder:builder zoneminder /home/builder/zoneminder/
# copy abuild rsa keys 
# you need to create your own!!!
# read the .abuild/readme for more information
#
COPY .abuild/builder*.rsa.pub /etc/apk/keys/.
COPY --chown=builder:builder .abuild /home/builder/.abuild/

COPY --chown=builder:builder buildall.sh /home/builder/.
RUN chmod u+x /home/builder/buildall.sh

COPY --chown=builder:builder lftpbookmarks /home/builder/.lftp/bookmarks


#COPY entrypoint.sh /entrypoint.sh
#RUN chmod 0755 /tmp/build/install.sh /entrypoint.sh
#RUN /tmp/build/install.sh

#EXPOSE 80

#ENV ZM_DB_TYPE=mysql ZM_DB_HOST=zm.db \
#    ZM_DB_PORT=3306 ZM_DB_NAME=zoneminder ZM_DB_USER=zoneminder \
#    ZM_DB_PASS=zoneminder

LABEL org.label-schema.build-date=$build_date org.label-schema.vcs-url="https://github.com/mmoerz/docker-zoneminder" org.label-schema.vcs-ref=$version org.label-schema.schema-version="1.0"

#ENTRYPOINT ["/entrypoint.sh"]
ENTRYPOINT ["/bin/ash"]
