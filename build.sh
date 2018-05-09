#!/bin/bash

version=$(git rev-parse --short HEAD)
build_date=$(date -Iseconds)
tagdate=$(echo $build_date | sed 's/-/_/g' | sed 's/:/_/g')

docker build --build-arg "version=$version" --build-arg "build_date=$build_date" -t jantman/zoneminder:${tagdate} .
#docker tag jantman/zoneminder:${tagdate} jantman/zoneminder:latest
