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
            echo "✓ finish building"

            docker run -v $PWD:/work -w /work --rm roam_textlint npx textlint -c ./.textlintrc $FILE
            if [ $? -gt 0 ]; then
                notify-send "Fail Textlint" ""
            fi
            echo "✓ finish textlint"
        fi
    done
}

# ページ一覧を更新する
dblock() {
    # 同じ監視ディレクトリ内での移動だから、moveだと2回発火する。なのでmoved_toかmove_fromを使う
    inotifywait -m -e moved_to --format '%w%f' . | while read FILE; do
        if [[ $FILE =~ .*org$ ]]; then
            echo "File $FILE was move ..."
            make update-dlinks
            echo "✓ update dblock"

            # 1ファイルの割に、このエクスポートは遅い。org-idのついたリンクのエクスポートはとても遅いようだ...
            emacs --batch -l ./publish.el \
                  --eval "(require 'org)" \
                  --eval "(find-file \"./dlinks.org\")" \
                  --eval "(org-publish-current-file)"
            echo "✓ finish dlinks building"
        fi
    done
}

modify &
dblock &
wait
