#!/bin/bash
set -eux

######################
# pandocでPDFに変換する
######################

cd `dirname $0`
cd ../

cmd() {
  mkdir -p pdf;
  find ./ -name "*.org" -type f -exec sh -c 'echo ${0} 2>$1; pandoc "${0}" -o "pdf/${0%.org}.pdf" --toc -N --pdf-engine=lualatex -V documentclass=ltjsarticle -V luatexjapresetoptions=morisawa' {} \;
  pdftk pdf/*.pdf cat output pdf/merge.pdf;
}

gen_pdf() {
    docker build --target pandoc -t roam-pandoc .

    docker run \
           --rm \
           -it \
           -T \
           -v $PWD:/work \
           -w /work \
           roam-pandoc \
           /bin/sh -c "`cmd`"
}

gen_pdf
