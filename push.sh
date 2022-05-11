#!/bin/sh

LC=$(git rev-parse --short HEAD)

docker build --target ruby -t ghcr.io/kijimad/roam_ruby:master --build-arg BUILDKIT_INLINE_CACHE=1 .
docker push ghcr.io/kijimad/roam_ruby:master

docker build --target build -t ghcr.io/kijimad/roam_build:${LC} -t ghcr.io/kijimad/roam_build:master --build-arg BUILDKIT_INLINE_CACHE=1 .
docker push ghcr.io/kijimad/roam_build:master
docker push ghcr.io/kijimad/roam_build:${LC}

docker build --target release -t ghcr.io/kijimad/roam_release:${LC} -t ghcr.io/kijimad/roam_release:master --build-arg BUILDKIT_INLINE_CACHE=1 .
docker push ghcr.io/kijimad/roam_release:master
docker push ghcr.io/kijimad/roam_release:${LC}

docker build --target lint -t ghcr.io/kijimad/roam_lint:master --build-arg BUILDKIT_INLINE_CACHE=1 .
docker push ghcr.io/kijimad/roam_lint:master
