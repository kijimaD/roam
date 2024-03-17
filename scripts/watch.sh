#!/bin/bash
set -u # 途中でエラーがあってもwatchを止めさせないためにeオプションはない

#################
# 自動ビルド + Lint
#################

cd `dirname $0`
cd ..

which inotifywait # 依存チェック

docker build . --target textlint -t roam_textlint

modify() {
    inotifywait -m -e modify --format '%w%f' . | while read FILE; do
        if [[ $FILE =~ .*org$ ]]; then
            echo "File $FILE was modified..."

            emacs --batch -l ./publish.el \
                  --eval "(require 'org)" \
                  --eval "(find-file \"./$FILE\")" \
                  --eval "(org-publish-current-file)"
            if [ $? -gt 0 ]; then
                notify-send "Fail Build" ""
            fi

            docker run -v $PWD:/work -w /work --rm roam_textlint npx textlint -c ./.textlintrc $FILE
            if [ $? -gt 0 ]; then
                notify-send "Fail Textlint" ""
            fi
        fi
    done
}

refresh() {
    inotifywait -m -e create --format '%w%f' . | while read FILE; do
        if [[ $FILE =~ .*org$ ]]; then
            echo "File $FILE was create or delete or rename..."
            # sitemapを更新する
            make org2html
        fi
    done
}

modify &
refresh &
wait
