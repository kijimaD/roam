#!/bin/sh
set -eux

cd `dirname $0`
cd ..

make file-graph line-graph update-index update-dlinks node-graph pmd-graph gen-file-table org2html
