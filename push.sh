#!/bin/sh

LC=$(git rev-parse --short HEAD)
docker build --target build -t ghcr.io/kijimad/roam:${LC} -t ghcr.io/kijimad/roam:master .
docker push ghcr.io/kijimad/roam:master
docker push ghcr.io/kijimad/roam:${LC}

docker build --target ruby -t ghcr.io/kijimad/roam_ruby:master .
docker push ghcr.io/kijimad/roam_ruby:master

docker build --target lint -t ghcr.io/kijimad/roam_lint:master .
docker push ghcr.io/kijimad/roam_lint:master
