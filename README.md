# docker-zoneminder

[ZoneMinder](https://www.zoneminder.com/) ([github](https://github.com/ZoneMinder/zoneminder)) running in a Docker container without a bundled DB.

This was forked from [pschmitt/docker-zoneminder](https://github.com/pschmitt/docker-zoneminder). His was the only example I could find of a somewhat sane dockerized ZoneMinder install; all I've done is try to get it running under a modern Alpine version.

This image uses supervisord to manage multiple processes. I know, it's ugly and un-Docker-like. But it's how ZoneMinder, a Perl application originally released in 2002, needs to run. There's the ZoneMinder Perl daemon itself (which also spawns other processes) and php-fpm and lighttpd for the web UI. At least, unlike ZoneMinder's [official Dockerfiles](https://github.com/ZoneMinder/zmdockerfiles), this image isn't based on CentOS or Ubuntu and doesn't include MySQL/MariaDB running in the same container.

For a quick overview of why it's like this, see the [ZoneMinder Components Documentation](http://zoneminder.readthedocs.io/en/stable/userguide/components.html).

# CURRENT STATUS

This is a work in progress and not yet working. The [pschmitt/docker-zoneminder](https://github.com/pschmitt/docker-zoneminder) image this is based on was last committed two years ago and the builds have been erroring for over a year.

At the moment I have the UI working without obvious errors and cameras can record, but viewing/streaming/playback is broken. I'm working on that.

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
    -m 300M --memory-reservation 200M --kernel-memory 25M \
    --memory-swappiness=0 \
    --cpu-period=250000 --cpu-quota=250000 \
    jantman/zoneminder
```

### Important Notes:

* The above example runs the database on the Docker host, which for me is 172.17.0.1. I manage my container with Puppet so it's trivial for me to find out that IP, but that would probably be done better with a modification to the entrypoint to find the default route at runtime.
* ZoneMinder runs and saves its data as the lighttpd user and group in the container, which should generally be UID 100 and GID 101. Be aware of that if mounting in host volumes for the images and events directories.
* The above configuration stores log files in the container itself under ``/var/log``, which will disappear if you restart the container. It's probably best to either make that a volume or mount it in from the host.
* __Note__ that ZoneMinder makes heavy use of shared memory files, i.e. ``/dev/shm``, for captures. You'll need to tune the ``--shm-size`` parameter for your number of cameras and resolution. There are tips for that [in the ZoneMinder wiki](https://wiki.zoneminder.com/Math_for_Memory_-_knowing_how_much_memory_you_need_and_how_to_optimize) and [on the forum](https://forums.zoneminder.com/viewtopic.php?f=11&t=9692&sid=5eb03841bd56e794c32586cc43531156). As a quick overview, I have a single Amcrest ProHD IP2M-841B camera running at 1080p (1920x1080) 30fps 32-bit color. For testing I have my image (ring) buffer setup left at the default of 50 frames. According to the formula in the wiki, that should require approximately 475MB of shared memory, which lines up well with my running ZoneMinder reporting that it's using 39% of the 1024MB shm specified.
* The above is an example of how I run this container on my own desktop computer. It includes some resource constraints as follows:
  * ``-m 300M`` - hard limit on 300MB of memory for container (see Docker docs on [memory constraints](https://docs.docker.com/engine/reference/run/#user-memory-constraints))
  * ``--memory-reservation 200M`` - soft limit on 200MB of memory
  * ``--kernel-memory 25M`` - limit to 25MB of kernel memory (stack pages, slab pages, sockets and tcp memory pressure; Docker docs on [kernel memory constraints](https://docs.docker.com/engine/reference/run/#kernel-memory-constraints))
  * ``--memory-swappiness=0`` - turn off anonymous page swapping for the container, under the assumption that ZoneMinder will be nearly constantly busy (Docker docs on [swappiness constraint](https://docs.docker.com/engine/reference/run/#swappiness-constraint))
  * ``--cpu-period=250000 --cpu-quota=250000`` - these enforce CPU bandwidth limits on the container, specificially giving it 100% of a CPU every 250ms period. See the Docker docs on [CPU period constraint](https://docs.docker.com/engine/reference/run/#cpu-period-constraint) and [CPU quota constraint](https://docs.docker.com/engine/reference/run/#cpu-quota-constraint) as well as the [CFS documentation on bandwidth limiting](https://www.kernel.org/doc/Documentation/scheduler/sched-bwc.txt). Note these settings only apply to machines using the default scheduler (CFS).

## Building

``./build.sh``

And then push to the registry.
