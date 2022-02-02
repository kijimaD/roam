#!/bin/sh

make file-graph && \
    make line-graph && \
    make update-index && \
    make node-graph && \
    make gen-file-table && \
    make build
