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
    --shm-size=1024m \
    jantman/zoneminder
```

### Important Notes:

* The above example runs the database on the Docker host, which for me is 172.17.0.1. I manage my container with Puppet so it's trivial for me to find out that IP, but that would probably be done better with a modification to the entrypoint to find the default route at runtime.
* ZoneMinder runs and saves its data as the lighttpd user and group in the container, which should generally be UID 100 and GID 101. Be aware of that if mounting in host volumes for the images and events directories.
* The above configuration stores log files in the container itself under ``/var/log``, which will disappear if you restart the container. It's probably best to either make that a volume or mount it in from the host.
* __Note__ that ZoneMinder makes heavy use of shared memory files, i.e. ``/dev/shm``, for captures. You'll need to tune the ``--shm-size`` parameter for your number of cameras and resolution. There are tips for that [in the ZoneMinder wiki](https://wiki.zoneminder.com/Math_for_Memory_-_knowing_how_much_memory_you_need_and_how_to_optimize) and [on the forum](https://forums.zoneminder.com/viewtopic.php?f=11&t=9692&sid=5eb03841bd56e794c32586cc43531156).

## Building

``./build.sh``

And then push to the registry.
