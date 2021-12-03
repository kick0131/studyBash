#!/bin/bash

# ファイルサイズ判定上限値(MB)
MAX_FILE_SIZE=1

# pcapファイル格納先ディレクトリ、ファイルパス
TARGET_DIR=/var/log
TARGET_FILEPATH=/var/log/*/*

# タイムスタンプ比較用ファイル
REF_FILE=tmpfile.txt

# 今日から何日以上過去日のファイルを削除対象とするか(dateコマンド -d フォーマット)
DATE_OPT='1 day ago'

LOGFILE="hoge.log"

func_log()
{
  echo -e "$(date '+%Y-%m-%dT%H:%M:%S') \
  (${BASH_SOURCE}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}

# touch -t オプションで特定のタイムスタンプファイル作成
create_reffile()
{
  TIME=`date '+%y%m%d0000' -d "$DATE_OPT"`
  touch -t $TIME $REF_FILE
}

# du -sxでサイズ指定し、cutコマンドで1要素目(サイズ)を取得
# -sk KB
# -sm MB
check_dir_capacity()
{
  dir_mbyte=`du -sm $TARGET_DIR | cut -f 1`
  if [ $dir_mbyte -gt $MAX_FILE_SIZE ]; then
    if [ $DRY_RUN == 1 ]; then
      echo "$TARGET_DIR size is $dir_mbyte MB"
    else
      func_log "$TARGET_DIR size is $dir_mbyte MB"
    fi
    return 1
  fi
  return 0
}

# ls -d でフルパス取得
# ()指定で配列要素として変数に入れ、ループ処理
delete_oldfiles()
{
  target_files=(`ls -d $TARGET_FILEPATH`)
  for file in "${target_files[@]}" ; do
    if [ $file -ot $REF_FILE ]; then
      if [ $DRY_RUN == 1 ]; then
        echo $file
      else
        func_log "delete $file"
        # ファイル削除処理
        :
      fi
    fi
  done
}


delete_olddirs()
{
  # 過去日タイムスタンプのディレクトリを削除
  # maxdepthで指定ディレクトリからの深さ
  # mtimeで過去日の条件を指定
  target_dirs=(`find $TARGET_DIR -maxdepth 1 -type d -mtime +0`)
  for target_dir in "${target_dirs[@]}" ; do
    if [ $DRY_RUN == 1 ]; then
      echo $target_dir
    else
      # ディレクトリ削除処理
      :
    fi
  done
}

# -nオプションで削除対象を表示するのみ(dry-run)
DRY_RUN=0
while getopts n OPT
do
    case $OPT in
        n)  DRY_RUN=1
            ;;
    esac
done

# main
func_log "start"
create_reffile
check_dir_capacity
if [ $? == 1 ]; then
  func_log "file size over"
  delete_olddirs
fi
delete_oldfiles

# 一時ファイルの削除
rm $REF_FILE

func_log "finished"
