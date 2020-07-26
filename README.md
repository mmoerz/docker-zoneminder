# docker-zoneminder

[![Project Status: Work in Progress – Initial development has started, but there has not yet been a stable, usable release; the project has been restarted and the developer intends to finish it.](https://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

[ZoneMinder](https://www.zoneminder.com/) ([github](https://github.com/ZoneMinder/zoneminder)) running in a Docker container without a bundled DB.

This was initialy forked from [pschmitt/docker-zoneminder](https://github.com/pschmitt/docker-zoneminder) by [jantman/docker-zoneminder](https://github.com/jantman/docker-zoneminder). I'm trying to get it working with a modern alpine Linux version.

Currently this repository provides a way to build zoneminder on a modern alpine Linux version and provides a way to create a docker image based on those packages. However this is completely untested and might fail utterly (so you have been warned).

For a quick overview of why it's like this, see the [ZoneMinder Components Documentation](http://zoneminder.readthedocs.io/en/stable/userguide/components.html).

# CURRENT STATUS

__Work in Progress.__

I've finally gotten streaming to work in this image, and (as far as I can tell) the image to be fully-functional. That required switching from lighttpd to Apache httpd, and I'm still not entirely sure why it wasn't working under lighttpd. So far, in the past week, I've spent four afternoons/evenings working on this, and I still don't have what I'd call a stable ZoneMinder install. Some issues:

* As a preface, I need to mention that ZoneMinder was first released in 2002. It is a mature, even aged, piece of software. The level of effort that has gone into it is astonishing, and the mere fact that it's still an active and well-respected project after 16 years is pretty damn amazing, even more so for an open source project. That being said, two of my main criteria for selecting home security/surveillance software are how stable I think it will be (will it run for weeks/months without me even looking at it, and be working when I need it to) and how easily I can customize it (code).
* ZoneMinder is a _giant_ codebase, made up of Perl, PHP, C++, JavaScript, and probably some others. There are just _so_ many moving pieces (see the [Components documentation](http://zoneminder.readthedocs.io/en/stable/userguide/components.html)) that I can't really imagine this running reliably without intervention for terribly long.
* As a corollary, when I did finally get this running, the logs (written to the DB and shown in the UI) kept reporting Errors (in red nonetheless) for processes that died and were then respawned by the watchdog without any noticeable effects in the UI/streams. I don't want to take on a system that doesn't even know the difference between an error and a warning, or that reports errors (with whistles and bells and sirens) to the user that it can self-recover from.
* Apparently Docker is now [a recommended install mathod](https://github.com/ZoneMinder/ZoneMinder/wiki/Docker), but the [official Dockerfiles](https://github.com/ZoneMinder/zmdockerfiles) (and almost all of the others I've found) are decidedly un-Docker-like, running _everything_ including both the web and DB tiers in one container. Given how many components make up ZoneMinder, it seems like it would much more naturally be made up of a handful of containers - maybe half a dozen plus a container per camera.
* Even on my main desktop computer - a relatively beefy machine for its day, with a 4-core/8-thread Intel i7-3770 @ 3.4GHz and 16GB DDR3 - ZoneMinder seemed to be struggling with two IP cameras and I saw occasional framerate drops down to 1-2fps. It just seems to be trying to do too much.
* I still think there's a ghost in the machine re: docker resource constraints. Once I set CPU or memory limits on the container, even if I set them way (i.e. 10x) above what Docker reports ZoneMinder to be using, ZM behaves differently and starts to have crippling performance issues.

Bottom line: I do a lot of work with Docker, and automating deployment and monitoring of software has been a big part of my job for the last decade. I need something that's simpler, feels more reliable, and is easier to deploy and monitor. Something that logs to STDOUT/STDERR, looks at least something like a 12-factor app, and feels like it can actually run (if not be designed) natively in Docker.

I'm going to be looking at [Shinobi](https://shinobi.video/) and [Kerberos.io](https://www.kerberos.io/), and most likely also looking at my old friend [Motion](https://motion-project.github.io/). Instead of figuring out how big of a dedicated computer I need, I'll almost certainly be running on a Raspberry Pi.

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
    -m 1024M --memory-reservation 500M \
    jantman/zoneminder
```

### Important Notes:

* The above example runs the database on the Docker host, which for me is 172.17.0.1. I manage my container with Puppet so it's trivial for me to find out that IP, but that would probably be done better with a modification to the entrypoint to find the default route at runtime.
* ZoneMinder runs and saves its data as the lighttpd user and group in the container, which should generally be UID 100 and GID 101. Be aware of that if mounting in host volumes for the images and events directories.
* The above configuration stores log files in the container itself under ``/var/log``, which will disappear if you restart the container. It's probably best to either make that a volume or mount it in from the host.
* __Note__ that ZoneMinder makes heavy use of shared memory files, i.e. ``/dev/shm``, for captures. You'll need to tune the ``--shm-size`` parameter for your number of cameras and resolution. There are tips for that [in the ZoneMinder wiki](https://wiki.zoneminder.com/Math_for_Memory_-_knowing_how_much_memory_you_need_and_how_to_optimize) and [on the forum](https://forums.zoneminder.com/viewtopic.php?f=11&t=9692&sid=5eb03841bd56e794c32586cc43531156). As a quick overview, I have a single Amcrest ProHD IP2M-841B camera running at 1080p (1920x1080) 30fps 32-bit color. For testing I have my image (ring) buffer setup left at the default of 50 frames. According to the formula in the wiki, that should require approximately 475MB of shared memory, which lines up well with my running ZoneMinder reporting that it's using 39% of the 1024MB shm specified.

## Building

``./build.sh``

And then push to the registry.
