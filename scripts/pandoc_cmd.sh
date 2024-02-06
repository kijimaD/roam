#!/bin/bash
set -eux

#########################################
# Dockerから呼び出される想定のPDFビルドコマンド
#########################################

cd `dirname $0`
cd ../

# MEMO: localeを日本にしないとファイルまわりで失敗する
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export TZ=Asia/Tokyo

mkdir -p pdf
find ./ -name "*.org" -type f -exec sh -c 'echo ${0}; pandoc "${0}" -o "pdf/${0%.org}.pdf" --toc -N --pdf-engine=lualatex -V documentclass=ltjsarticle -V luatexjapresetoptions=morisawa && echo ok' {} \;
pdftk pdf/*.pdf cat output pdf/insomnia.pdf
