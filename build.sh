#!/bin/bash

version=$(git rev-parse --short HEAD)
build_date=$(date -Iseconds)
#tagdate=$(echo $build_date | sed 's/-/_/g' | sed 's/:/_/g')
tagdate=$(date +%Y_%m_%d__%H%M)
gituser=$(git config --global user.name)

docker build --no-cache --build-arg "version=$version" \
  --build-arg "build_date=$build_date" -t $gituser/zoneminder:${tagdate} build
docker tag $gituser/zoneminder:${tagdate} $gituser/zoneminder:latest

echo -en "building finished\n\tVersion: $version\n"
