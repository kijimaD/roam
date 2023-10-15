#!/bin/sh
set -eux

make file-graph && \
    make line-graph && \
    make update-index && \
    make node-graph && \
    make pmd-graph && \
    make gen-file-table && \
    make org2html
