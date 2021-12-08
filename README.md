[![textlint](https://github.com/kijimaD/roam/actions/workflows/lint.yml/badge.svg)](https://github.com/kijimaD/roam/actions/workflows/lint.yml)
# roam note

- Notes using Emacs package: Org Roam https://github.com/org-roam/org-roam
- published by Emacs.

## build
```
make build # build site

make roam-graph # generate graph
```

## lint
```shell
npm install

make lint
```

## git hooks
```shell
git config --local core.hooksPath .githooks
git config --local commit.template .githooks/commit_msg.txt
chmod -R +x .githooks/
```
