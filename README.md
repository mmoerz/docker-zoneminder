# docker-zoneminder

[![Project Status: Work in Progress – Initial development has started, but there has not yet been a stable, usable release; the project has been restarted and the developer intends to finish it.](https://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

[ZoneMinder](https://www.zoneminder.com/) ([github](https://github.com/ZoneMinder/zoneminder)) running in a Docker container without a bundled DB.

This was initialy forked from [pschmitt/docker-zoneminder](https://github.com/pschmitt/docker-zoneminder) by [jantman/docker-zoneminder](https://github.com/jantman/docker-zoneminder). I'm trying to get it working with a modern alpine Linux version.

Currently this repository provides a way to build zoneminder on a modern alpine Linux version and provides a way to create a docker image based on those packages. However this is completely untested and might fail utterly (so you have been warned).

Going forward I will possibly try to remove the need of supervisord, which is at the moment the required way to handle running the zoneminder daemons.
For a quick overview of why it's like this, see the [ZoneMinder Components Documentation](http://zoneminder.readthedocs.io/en/stable/userguide/components.html).

# CURRENT STATUS

__Work in Progress.__

stay tuned for changes in the next few days I will try to get zoneminder running with a split off database and webserver configuration for a start.

## Running

quite diffucult atm, either wait for me to put up a docker image at the docker hub, or suit yourself and build it.

## Building

Following command builds the docker image for building the necessary alpine packages.

``./build.sh``

Afterwards run an interactive session on the container and execute:

``build-all``

This will result in creating a repository structure for alpine under 'packages'. Those then can be used to install zoneminder on the current rolling release of alpine 13.2 (at the time of writing). 


And then push to the registry.
