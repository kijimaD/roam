#!/bin/bash
set -eux

############################
# 使ってないファイルを検知して、
# 削除するスクリプト
############################

for x in images/*; do
    i=`git grep -c $x | wc -l`

    if [ $i -eq 0 ]; then
        rm $x
        echo "🚮 $x"
    else
        echo "✓ $x"
    fi
done
