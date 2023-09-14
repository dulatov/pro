#!/bin/bash
[ $(id -u) -gt 0 ] && echo «Пожалуйста, выполните этот сценарий под sudo!» && exit 1
sysversion=$(rpm -q centos-release|cut -d- -f3)
date=`date +%Y-%m-%d`
MYSQL=/usr/bin/mysql
ACCOUNT=`cat /home/mdulatov/scripts/.my.cnf`
echo "-uroot -p$ACCOUNT" > /home/mdulatov/.my.cnf
MYCONN=`cat /home/mdulatov/.my.cnf`
DUMP=/usr/bin/mysqldump
DUMPOPTIONS="-ceqQ --single-transaction --add-drop-table --allow-keywords --events" 
BKPDIR="/var/backup/sync/mysql/"
DBASES_DIR="$BKPDIR/$date/db"
TABLES_DIR="$BKPDIR/$date/tables"
/usr/bin/mysql $MYCONN -e 'stop master; exit;';
DATABASES=`$MYSQL $MYCONN -Bse 'show databases'|grep -vP 'information_schema|performance_schema'`
mkdir -p $DBASES_DIR
    for i in $DATABASES; do
    if [ "$i" = "test" ];
    then
        continue
    fi
    echo $DATABASES:;
	$DUMP $MYCONN $DUMPOPTIONS $i $j $DATABASES: | gzip -1 > $DATABASES.sql.gz
        [ ! -d $TABLES_DIR/$i ] && mkdir -p $TABLES_DIR/$i
	schem="\`$i\`"
	TABLES=`$MYSQL $MYCONN -Bse "show tables from $schem"`
	for j in $TABLES;do
        echo $i ___ $j ;
        $DUMP $MYCONN $DUMPOPTIONS $i $j | gzip -1 > $TABLES_DIR/$i/$j.sql.gz
	done;
done;
/usr/bin/mysql $MYCONN -e 'start master; show slave status\G; exit;'
