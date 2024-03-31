PDFスライド集。

## 変換

drawio SVG -> PDFへの変換にはdrawioコマンドが必要。

https://github.com/jgraph/drawio-desktop/releases/tag/v24.1.0

一気に変換する。

```
  $ ls | grep '.drawio.svg$' | xargs drawio -f pdf -x
```

## Docker

フォントまわりで罠があったりするので、CI環境を再現したい用。

```
docker build . --target builder -t test
docker run --rm -it -v "$PWD/":/roam test /bin/sh
```
