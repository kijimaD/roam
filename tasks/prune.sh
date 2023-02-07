#!/bin/bash

for x in images/*; do
    i=`git grep -c $x | wc -l`

    if [ $i -eq 0 ]; then
        rm $x
        echo "🚮 $x"
    else
        echo "✓ $x"
    fi
done
