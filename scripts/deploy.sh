#!/bin/sh
set -eux

cd `dirname $0`
cd ..

# PDF生成。一覧リストの更新のため、一覧更新より先にやる必要がある
which drawio && which xvfb-run # コマンドがあるか確認
cd ./pdfs
ls | grep 'pdf.drawio.svg' | xargs -I {} xvfb-run drawio -f pdf -x {} --no-sandbox
cd ..

make file-graph line-graph update-index update-dlinks node-graph pmd-graph gen-file-table org2html
