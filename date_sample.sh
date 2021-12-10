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

#
# 日付ディレクトリ名から日数超過を判定
#
datesample()
{
  # 超過日数
  EXPIRE=10

  # 判定対象
  target_date=`date '+%Y%m%d'`
  target_date=`date '+%Y%m%d' -d "2021/10/01"`

  # 超過基準の日付
  expire_date=`date '+%Y%m%d' -d "$EXPIRE day ago"`
  expire_date_sec=`date -d"$expire_date" +%s`
  target_date_sec=`date -d"$target_date" +%s`
  echo $target_date $expire_date

  # 日付の差分
  period_day=`expr \( $target_date_sec - $expire_date_sec \) / 60 / 60 / 24`
  echo $period_day
  # 日数超過判定
  if [ $period_day -le 0 ]; then
    echo "$target_date is expire"
  else
    echo "$target_date is not expire"
  fi
}
