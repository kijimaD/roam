#!/bin/bash
set -eu

#################
# 自動ビルド + Lint
#################

cd `dirname $0`
cd ..

 which inotifywait # 依存チェック

docker build . --target textlint -t roam_textlint

inotifywait -m -e modify --format '%w%f' . | while read FILE; do
  if [[ $FILE =~ .*org$ ]]; then
      echo "File $FILE was modified..."

      emacs --batch -l ./publish.el \
            --eval "(require 'org)" \
            --eval "(find-file \"./$FILE\")" \
            --eval "(org-publish-current-file)"
      docker run -v $PWD:/work -w /work --rm roam_textlint npx textlint -c ./.textlintrc $FILE
  fi
done
