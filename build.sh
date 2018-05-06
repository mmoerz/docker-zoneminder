#!/bin/bash

version=$(git rev-parse --short HEAD)
build_date=$(date -Iseconds)
tagdate=$(echo $build_date | sed 's/-/_/g' | sed 's/:/_/g')

docker build --no-cache --build-arg "version=$version" --build-arg "build_date=$build_date" -t jantman/zoneminder:${tagdate} .
