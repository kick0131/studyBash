#!/bin/bash

#
# ディレクトリ名のフォーマットチェック
# - 時刻フォーマット形式(yyyymmdd)かのチェック
#
dir_dateformatcheck()
{
  target_dirs=("/tmp/20211201" "/tmp/20211202")
  for target_dir in "${target_dirs[@]}" ; do
    echo $target_dir
    # ディレクトリ名のみ抽出
    dirname=`echo $target_dir | awk -F "/" '{ print $NF }'`

    # フォーマット判定
    # 日付型に変換できた場合にチェックを実施
    # 変換できない場合は空文字になり、評価は偽になる
    if [ "`date +'%Y%m%d' -d $dirname 2> /dev/null`" = $dirname ]; then
      echo "$target_dir delete"
    fi
  done
}

