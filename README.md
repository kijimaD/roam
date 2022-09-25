[![textlint](https://github.com/kijimaD/roam/actions/workflows/lint.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/lint.yml)
[![Publish to GitHub Pages](https://github.com/kijimaD/roam/actions/workflows/publish.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/publish.yml)

<img src="https://user-images.githubusercontent.com/11595790/192126280-7078c271-d0ca-4c7b-9aa8-ed4e5a4bccb6.png" width="40%" align=right>

# Org Roam notes

- Notes by Emacs package Org Roam https://github.com/org-roam/org-roam

+ production: https://kijimad.github.io/roam/
+ staging: https://roam-staging.herokuapp.com/
+ monitor: https://kijimad.github.io/roam_upptime/

## development

```shell
make org2html
make server
```

## lint
```shell
npm install
make textlint
```

## git hooks
settings for conventional commit

```shell
git config --local core.hooksPath .githooks
git config --local commit.template .githooks/commit_msg.txt
```
