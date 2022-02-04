[![textlint](https://github.com/kijimaD/roam/actions/workflows/lint.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/lint.yml)
[![Publish to GitHub Pages](https://github.com/kijimaD/roam/actions/workflows/publish.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/publish.yml)
[![Docker build](https://github.com/kijimaD/roam/actions/workflows/docker.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/docker.yml)

# Org Roam note

- Notes using Emacs package: Org Roam https://github.com/org-roam/org-roam
- written by Emacs, published by Emacs.

## lint
```shell
npm install
make lint
```

## git hooks
settings for conventional commit

```shell
git config --local core.hooksPath .githooks
git config --local commit.template .githooks/commit_msg.txt
```

## docker
repository image: https://github.com/users/kijimaD/packages/container/package/roam

build(use docker-compose)
```shell
make deploy-dev
```

development
```shell
docker-compose pull
docker-compose run roam
```
