#!/bin/bash
set -eux

############################
# PandocでPDFに変換するコマンド
############################

cd `dirname $0`
cd ../

gen_pdf() {
    docker build --target pandoc -t roam-pandoc .

    docker run \
           --rm \
           -t \
           -v $PWD:/work \
           -w /work \
           roam-pandoc \
           /bin/sh -c "./scripts/pandoc_cmd.sh"
}

gen_pdf
