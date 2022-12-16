#!/bin/bash
echo "Не забудьте выключить репликацию";
echo "Enter date restore YYYY-MM-DD"
read DATE
echo "Enter DB name to restore"
read DBRESTORE
echo "Full restore DB or tables?: DB/TB"
read RESTOTYPE
MYSQL=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
DUMPOPTIONS="-ceqQ --single-transaction --add-drop-table --allow-keywords --events"
ACCOUNT=`cat /home/mdulatov/.my.cnf` # данные для подключения к MySQL 
BKPDIR="/var/backup/sync/mysql"
DBASES_DIR="$BKPDIR/$DATE/db"
TABLES_DIR="$BKPDIR/$DATE/tables"
if [ ${RESTOTYPE^^} == "DB" ]; then
$DUMP $ACCOUNT $DBRESTORE < $DBASES_DIR/$DBRESTORE | gzip -d
echo #$DBRESTORE восстановлена"
  else
  ls $TABLES_DIR/$DBRESTORE | grep sql.gz
    echo "Select a table to restore"
    read SELTABLE
    $DUMP $ACCOUNT $DBRESTORE < $TABLES_DIR/$DBRESTORE/$SELTABLE | gzip -d
    echo "$TABLES_DIR/$SELTABLE"
    echo "Продолжить восстановление таблиц? Y/N"
    read CONTINUE
     while [ ${CONTINUE^^} == "Y" ]
     do
     ls $TABLES_DIR/$DBRESTORE  | grep sql.gz
     echo "Выбирите таблицу"
     read SELTABLE
     $DUMP $ACCOUNT $DBRESTORE < $TABLES_DIR/$DBRESTORE/$SELTABLE | gzip -d
     echo "Таблица $SELTABLE восстановлена."
     echo "Продолжить восстановление таблиц? Y/N"
     read CONTINUE
     done
  fi
