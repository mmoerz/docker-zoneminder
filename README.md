# docker-zoneminder

[ZoneMinder](https://www.zoneminder.com/) ([github](https://github.com/ZoneMinder/zoneminder)) running in a Docker container without a bundled DB.

This was forked from [pschmitt/docker-zoneminder](https://github.com/pschmitt/docker-zoneminder). His was the only example I could find of a somewhat sane dockerized ZoneMinder install; all I've done is try to get it running under a modern Alpine version.

This image uses supervisord to manage multiple processes. I know, it's ugly and un-Docker-like. But it's how ZoneMinder, a Perl application originally released in 2002, needs to run. There's the ZoneMinder Perl daemon itself (which also spawns other processes) and php-fpm and lighttpd for the web UI. At least, unlike ZoneMinder's [official Dockerfiles](https://github.com/ZoneMinder/zmdockerfiles), this image isn't based on CentOS or Ubuntu and doesn't include MySQL/MariaDB running in the same container.

## Running

You can ``docker pull jantman/zoneminder:latest`` or build it yourself.

An example of running the container, bound to port 8000 on the host and using 172.17.0.1 as the MySQL DB host, and with image and event data stored on the host in ``/mnt/space3/zoneminder/images`` and ``/mnt/space3/zoneminder/events`` respectively:

```
docker run -it --name zoneminder \
    -e ZM_DB_HOST=172.17.0.1 \
    -p 8000:80 \
    -v /mnt/space3/zoneminder/images:/usr/share/webapps/zoneminder/htdocs/images \
    -v /mnt/space3/zoneminder/events:/usr/share/webapps/zoneminder/htdocs/events \
    jantman/zoneminder
```

Note that ZoneMinder runs and saves its data as the lighttpd user and group in the container, which should generally be UID 100 and GID 101.

/usr/share/webapps/zoneminder/htdocs ???

## Building

``./build.sh``

And then push to the registry.
