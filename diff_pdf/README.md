# diff_pdfバッチ処理

## 概要
[diff-pdf](https://vslavik.github.io/diff-pdf/) をバッチ処理します。

指定のディレクトリに配置されているPDFファイルを比較し、比較結果をdiff.pdfというファイル名でファイル出力する。

## 要件
* Windows
* Ruby
* [diff-pdf](https://vslavik.github.io/diff-pdf/) のexeファイル

## 使い方
必須引数は以下
* ` -t [ディレクトリパス] `で処理するディレクトリパスを指定する。
* `-a [比較する(1)PDFファイルの接頭語]`で比較するPDFファイルの接頭語を指定する。
* `-b [比較する(2)PDFファイルの接頭語]`で比較するもう一方のPDFファイルの接頭語を指定する。

```
ruby main.rb -t "C:\hoge" -a "after" -b "before" 
```

オプションは以下
* `-s` 差分があるページのみを出力する
* `-m` ページの左側に相違箇所にしるしを付ける

```
ruby main.rb -t "C:\hoge" -a "after" -b "before" -s -m
```

