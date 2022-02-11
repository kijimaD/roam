#!/bin/sh

git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git add .
git commit -m 'chore: auto'

make file-graph && \
    make line-graph && \
    make update-index && \
    make node-graph && \
    make gen-file-table && \
    make org2html
