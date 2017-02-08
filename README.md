# insertHoliday.sh

## 説明
csv/のファイルをSQLにしてsql/へ出力

## 条件
csv の形式
```
YYYY-MM-DD,holiday
YYYY-MM-DD,holiday
YYYY-MM-DD,holiday
```

## 使い方
1. 国民の祝日csvを./csvに配置
2. 実行
```
$ ./insertHoliday.sh
```

### 設定箇所
ファイルを開き、以下の箇所を修正することでSQLに「お盆休み」と「冬休み」を追加する。
```
VACATIONS=(14 15 29 30 31 01 02 03 04)
```
日付<10 : YYYY(来年の西暦)-mm(1月)-日付
または日付<20 : YYYY(今年の西暦)-mm(8月)-日付
それ以外の日付 : YYYY(今年の西暦)-mm(12月)-日付

他、ファイル名、ディレクトリ名へ好きに変えられる。
