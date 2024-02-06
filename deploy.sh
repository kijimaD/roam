#!/bin/sh
set -eux

make file-graph line-graph update-index node-graph pmd-graph gen-file-table make org2html
