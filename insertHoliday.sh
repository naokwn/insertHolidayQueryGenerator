#!/bin/sh

##
# Usage : ./insertHoliday.sh 
# csv/のファイルをSQLにしてsql/へ出力
#
# VACATIONS に 日付を設定することで、お盆、冬休みを国民の祝日リストへ追加して出力
#
VACATIONS=(14 15 29 30 31 01 02 03 04)
#
# 日付csvのあるディレクトリ
INPUTDIR="csv"
#
# 日付csvファイル
INPUTFILE=$INPUTDIR/data.csv
#
# 出力先ディレクトリ
OUTPUTDIR="sql"
#
# 出力先ファイル
OUTPUTFILE=$OUTPUTDIR/insert.sql

IFS_BACKUP=$IFS
IFS=$'\n'
cp ${INPUTFILE} ${INPUTFILE}.tmp
TMP=${INPUTFILE}.tmp

if [ $# -ne 1 ] ; then
  echo "Usage : ./insertHoliday.sh <csv>"
  exit 1
elif [ ! -e $INPUTFILE ] ; then
  echo "祝日csvファイルを指定のディレクトリ'./${INPUTDIR}'に配置してください"
  exit 1
elif [ -e $OUTPUTFILE ] ; then
  echo "古い${OUTPUTFILE}を削除しました"
  rm $OUTPUTFILE
fi

if [ -n $VACATIONS ] ; then
  UNAME=`uname`
  TMPSORTED=${INPUTFILE}.sort.tmp
  for DAY in ${VACATIONS[@]} 
  do
    if [ $DAY -lt 10 ] ; then
      if [ $UNAME = "Darwin" ] ; then
        YEAR=`date -v+1y +"%Y"`
      elif [ $UNAME = "Linux" ] ; then
        YEAR=`date +"%Y" -d "next year"`
      fi
      YMD="${YEAR}-01-${DAY}"
      TEXT="冬期休暇"
    elif [ $DAY -lt 20 ] ; then
      YEAR=`date +"%Y"`
      YMD="$YEAR-08-$DAY"
      TEXT="お盆休み"
    else
      YEAR=`date +"%Y"`
      YMD="$YEAR-12-$DAY"
      TEXT="冬期休暇"
    fi
    echo "$YMD,$TEXT" >> $TMP
  done

  cat $TMP | sort >> $TMPSORTED
  DIFF=`diff $INPUTFILE $TMPSORTED`
  echo "追加された祝日\n \`\`\` \n$DIFF\n\`\`\`"
  
  rm $TMP
  unset TMP
  TMP=$TMPSORTED
fi

QUERY="INSERT INTO \`holidays\` (\`holiday\`, \`memo\`, \`created\`, \`modified\`) VALUES\n"
for line in `cat $TMP`
do
  DATE=`echo $line | cut -d ',' -f 1`
  HOLIDAY=`echo $line | cut -d ',' -f 2 | sed 's/"//g'`
  QUERY="$QUERY ('$DATE', '$HOLIDAY', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),\n" 
done

echo $QUERY | sed '/^$/d' > $OUTPUTFILE
WCL=`cat $OUTPUTFILE | wc -l`
cat $OUTPUTFILE | (rm $OUTPUTFILE; sed "$WCL s/,$/;/g" > $OUTPUTFILE)

rm $TMP
IFS=$IFS_BACKUP

echo "done!"
