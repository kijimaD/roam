#!/bin/bash
set -u # 途中でエラーがあってもwatchを止めさせないためにeオプションはない

#################
# 自動ビルド + Lint
#################

cd `dirname $0`
cd ..

which inotifywait # 依存チェック

docker build . --target textlint -t roam_textlint

# orgファイルの更新時フック
modifyorg() {
    inotifywait -m -e modify --format '%w%f' . | while read FILE; do
        if [[ $FILE =~ .*org$ ]]; then
            echo "File $FILE was modified..."
            # 対象ページのビルド
            emacs --batch -l ./publish.el \
                  --eval "(require 'org)" \
                  --eval "(find-file \"./$FILE\")" \
                  --eval "(org-publish-current-file)"
            if [ $? -gt 0 ]; then
                notify-send "Fail Build" ""
            fi
            echo "✓ finish building"

            docker run -v $PWD:/work/roam -w /work --rm roam_textlint bash -c "npx textlint -c ./.textlintrc ./roam/$FILE"
            if [ $? -gt 0 ]; then
                notify-send "Fail Textlint" ""
            fi
            echo "✓ finish textlint"
        fi
    done
}

# 画像ファイルの更新フック
modifyimage() {
    inotifywait -m -e modify --format '%w%f' ./images | while read FILE; do
        if [[ $FILE =~ \./images/.* ]]; then
            # 画像を反映する
            cp -r images public/

            # 一覧ページ更新(org)
            make update-dlinks
            echo "✓ update dblock"
        fi
    done
}

# ページ一覧を更新する
dblock() {
    # 同じ監視ディレクトリ内での移動だから、moveだと2回発火する。なのでmoved_toかmove_fromを使う
    inotifywait -m -e moved_to --format '%w%f' . | while read FILE; do
        if [[ $FILE =~ .*org$ ]]; then
            echo "File $FILE was move ..."
            # 対象ページのビルド
            emacs --batch -l ./publish.el \
                  --eval "(require 'org)" \
                  --eval "(find-file \"./$FILE\")" \
                  --eval "(org-publish-current-file)"

            # 一覧ページ更新(org)
            make update-dlinks
            echo "✓ update dblock"

            # 一覧ページのビルド(html)
            # 1ファイルの割に、このエクスポートは遅い。org-idのついたリンクのエクスポートはとても遅いようだ...
            emacs --batch -l ./publish.el \
                  --eval "(require 'org)" \
                  --eval "(find-file \"./dlinks.org\")" \
                  --eval "(org-publish-current-file)"
            echo "✓ finish dlinks building"
        fi
    done
}

modifyorg &
modifyimage &
dblock &
wait
