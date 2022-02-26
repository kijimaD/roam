[![textlint](https://github.com/kijimaD/roam/actions/workflows/lint.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/lint.yml)
[![Publish to GitHub Pages](https://github.com/kijimaD/roam/actions/workflows/publish.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/publish.yml)

# Org Roam note

- Notes by Emacs package: Org Roam https://github.com/org-roam/org-roam
- written by Emacs, published by Emacs.

+ production: https://kijimad.github.io/roam/
+ staging: https://roam-staging.herokuapp.com/

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
