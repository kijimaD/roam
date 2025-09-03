#!/bin/bash

###################################
# KDOC番号の重複をチェックするスクリプト #
###################################

set -eu

cd `dirname $0`
cd ..

echo "KDOC番号の重複をチェックしています..."

# kdocファイルからKDOC番号を抽出し、重複を確認
kdoc_numbers=$(ls -1 | grep kdoc | grep -o 'kdoc-[0-9]*' | sort)

# 重複している番号を検出
duplicates=$(echo "$kdoc_numbers" | uniq -d)

if [ -z "$duplicates" ]; then
    echo "重複しているKDOC番号はありません。"
else
    echo "重複しているKDOC番号が見つかりました:"
    echo "$duplicates"
    echo
    echo "詳細:"
    for dup in $duplicates; do
        echo "[$dup] の重複ファイル:"
        ls -1 | grep "$dup"
        echo
    done
    exit 1
fi

# 抜けている番号も確認
echo "抜けているKDOC番号をチェックしています..."
numbers_only=$(echo "$kdoc_numbers" | sed 's/kdoc-//' | sort -n | uniq)
max_num=$(echo "$numbers_only" | tail -1)

missing_numbers=""
for ((i=1; i<=max_num; i++)); do
    if ! echo "$numbers_only" | grep -q "^$i$"; then
        missing_numbers="$missing_numbers $i"
    fi
done

if [ -n "$missing_numbers" ]; then
    echo "抜けているKDOC番号:$missing_numbers"
else
    echo "抜けているKDOC番号はありません。"
fi
