FROM alpine:3.11

# MAINTAINER Philipp Schmitt <philipp@schmitt.co>
# MAINTAINER Jason Antman <jason@jasonantman.com>
MAINTAINER Michael Moerz <michael@moerz.co.at>

ARG version
ARG build_date
ARG buildusername

#RUN apk update \
#RUN echo "@edgetest http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
#    && apk update \
RUN apk update \
    && apk add --no-cache \
 bash alpine-sdk automake autoconf libtool pkgconf cmake apkbuild-cpan \
 jansson-dev doxygen check check-dev libxaw graphviz \
 perl-dev perl-utils git-perl perl-git perl-error perl libbz2 \
 bzip2-dev gzip zip lftp \
 polkit vlc x264 gzip \
 libjpeg-turbo-dev curl-dev openssl-dbg mariadb-dev expat-dev \ 
 ffmpeg-dev x264-dev pcre-dev libgcrypt-dev vlc-dev libvncserver-dev \
 libexecinfo-dev polkit-dev \
 perl perl-archive-zip perl-date-manip perl-dbd-mysql \
 perl-dbi perl-device-serialport perl-libwww \
 perl-lwp-protocol-https perl-mailtools perl-mime-lite \
 perl-mime-tools perl-php-serialization perl-sys-meminfo perl-sys-mmap \
 perl-time-hires perl-term-readkey perl-test-taint perl-module-runtime \
 perl-xml-parser perl-sub-identify perl-appconfig perl-sub-install \
 perl-b-hooks-endofscope perl-variable-magic perl-package-stash \
 perl-template-toolkit perl-class-load perl-data-optlist  perl-params-util \
 perl-namespace-clean perl-sub-name \
   polkit-dev vlc-dev x264-dev gzip zip nginx \
   mariadb-connector-c-dev pcre-dev \
 php7 php7-apcu php7-ctype php7-gd php7-json \
 php7-pdo_mysql php7-session php7-sockets \
           bzip2 ffmpeg libproc procps

#
#        perl-data-uuid \
#        perl-data-dump perl-log-log4perl \
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

# user for building the packages
RUN adduser -D $buildusername
RUN addgroup $buildusername abuild

COPY abuild/*.rsa.pub /etc/apk/keys/.

# copy all apks to build
#
COPY --chown=$buildusername:$buildusername apks/ /home/$buildusername/
# copy abuild rsa keys 
# you need to create your own!!!
# read the .abuild/readme for more information
#
COPY --chown=$buildusername:$buildusername abuild /home/$buildusername/.abuild/
# 
# copy lfp bookmarks (for upload)
#
COPY --chown=$buildusername:$buildusername lftp /home/$buildusername/.lftp
#
# copy helper scripts for building / uploading
#
COPY --chown=$buildusername:$buildusername bin /home/$buildusername/bin
# include bin dir in $PATH
COPY --chown=$buildusername:$buildusername bashrc /home/$buildusername/.bashrc

LABEL org.label-schema.build-date=$build_date org.label-schema.vcs-url="https://github.com/mmoerz/docker-zoneminder/build" org.label-schema.vcs-ref=$version org.label-schema.schema-version="1.0"

#ENTRYPOINT ["/entrypoint.sh"]
USER $buildusername
WORKDIR /home/$buildusername
CMD ["/bin/bash"]
