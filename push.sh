#!/bin/sh

LC=$(git rev-parse --short HEAD)

docker buildx --target ruby -t ghcr.io/kijimad/roam_ruby:master --build-arg BUILDKIT_INLINE_CACHE=1 --progress .
docker push ghcr.io/kijimad/roam_ruby:master

docker buildx --target build -t ghcr.io/kijimad/roam_build:${LC} -t ghcr.io/kijimad/roam_build:master --build-arg BUILDKIT_INLINE_CACHE=1 --progress .
docker push ghcr.io/kijimad/roam_build:master
docker push ghcr.io/kijimad/roam_build:${LC}

docker buildx --target release -t ghcr.io/kijimad/roam_release:${LC} -t ghcr.io/kijimad/roam_release:master --build-arg BUILDKIT_INLINE_CACHE=1 --progress .
docker push ghcr.io/kijimad/roam_release:master
docker push ghcr.io/kijimad/roam_release:${LC}

docker buildx --target lint -t ghcr.io/kijimad/roam_lint:master --build-arg BUILDKIT_INLINE_CACHE=1 --progress .
docker push ghcr.io/kijimad/roam_lint:master
