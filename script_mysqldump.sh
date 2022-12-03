#!/bin/bash

date=`date +%Y-%m-%d`
MYSQL=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
DUMPOPTIONS="-ceqQ --single-transaction --add-drop-table --allow-keywords --events"
ACCOUNT=`cat /home/mdulatov/scripts/.my.cnf` # данные для подключения к MySQL
PASS=`cat /home/mdulatov/scripts/.pass` # пароль для шифрования архива
BKPDIR="/var/backup/sync/mysql/"
DBASES_DIR="$BKPDIR/$date/db"
TABLES_DIR="$BKPDIR/$date/tables"
/usr/bin/mysql $ACCOUNT -e 'stop slave; exit;';
DATABASES=`$MYSQL $ACCOUNT -Bse 'show databases'|grep -vP 'information_schema|performance_schema'`
mkdir -p $DBASES_DIR
for i in $DATABASES; do
    if [ "$i" = "test" ];
    then
        continue
    fi
    echo $DATABASES:;
    [ ! -d $TABLES_DIR/$i ] && mkdir -p $TABLES_DIR/$i
    schem="\`$i\`"
    TABLES=`$MYSQL $ACCOUNT -Bse "show tables from $schem"`
    for j in $TABLES;do
        echo $i ___ $j ;
        $DUMP $ACCOUNT $DUMPOPTIONS $i $j | gzip -1 > $TABLES_DIR/$i/$j.sql.gz
        zcat $TABLES_DIR/$i/$j.sql.gz | bzip2 -c | tee -a $DBASES_DIR/$i.sql.bz2 > $TABLES_DIR/$i/$j.sql.bz2 && rm -f $TABLES_DIR/$i/$j.sql.gz
        openssl enc -aes-256-cbc -salt -pass pass:$PASS -in $TABLES_DIR/$i/$j.sql.bz2 -out $TABLES_DIR/$i/$j.sql.bz2.enc
        rm -f $TABLES_DIR/$i/$j.sql.bz2
    done;
done;
/usr/bin/mysql $ACCOUNT -e 'start slave; show slave status\G; exit;';

