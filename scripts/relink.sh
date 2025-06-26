#!/bin/bash
set -eu

##############################
# サイト内リンクのタイトルを更新する
##############################

cd `dirname $0`
cd ..

TARGET_FILE="$1"

if [[ -z "$TARGET_FILE" ]]; then
  echo "使い方: $0 <IDとタイトルを含むファイル>"
  exit 1
fi

ID="$(grep '^:ID:' "$TARGET_FILE" | awk '{print $2}')"
TITLE=$(grep '^#+title:' "$TARGET_FILE" | sed -n 's/^#+title:[ \t]*\(KDOC.*\)/\1/p')

if [[ -z "$ID" || -z "$TITLE" ]]; then
  echo "ID または TITLE が見つかりません: $TARGET_FILE"
  exit 1
fi

# すべての org ファイルでリンク置換を実行する
find . -name '*.org' | while read LINK_FILE; do
  # 対象ファイル自身はスキップ
  if [[ "$LINK_FILE" == "$TARGET_FILE" ]]; then
    continue
  fi

  if grep -q "\[\[id:$ID\]\[" "$LINK_FILE"; then
    sed -i -E "s|\[\[id:$ID\]\[[^]]*\]\]|[[id:$ID][$TITLE]]|g" "$LINK_FILE"
    echo "置換完了: $LINK_FILE の id:$ID リンクタイトルを更新"
  fi
done
