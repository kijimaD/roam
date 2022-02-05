#!/bin/sh

export DOCKER_BUILDKIT=1

LC=$(git rev-parse --short HEAD)
docker build --target build -t ghcr.io/kijimad/roam:${LC} .
docker push ghcr.io/kijimad/roam:${LC}
