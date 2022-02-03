#!/bin/sh

LC=$(git rev-parse --short HEAD)
docker build -t ghcr.io/kijimad/roam:${LC} .
docker push ghcr.io/kijimad/roam:${LC}