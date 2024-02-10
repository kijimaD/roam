#!/bin/bash
set -eu

#########
# 自動更新
#########

cd `dirname $0`
cd ..

inotifywait -m -e modify --format '%w%f' . | while read FILE; do
  if [[ $FILE =~ .*org$ ]]; then
      echo "File $FILE was modified..."
      filename_without_extension="${FILE%.org}"
      emacs --batch -l ./publish.el \
            --eval "(require 'org)" \
            --eval "(find-file \"./$FILE\")" \
            --eval "(org-publish-current-file)"
  fi
done
