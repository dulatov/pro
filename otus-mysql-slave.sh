#!/bin/bash
[ $(id -u) -gt 0 ] && echo «Пожалуйста, выполните этот сценарий под sudo!» && exit 1
sysversion=$(rpm -q centos-release|cut -d- -f3) 

sudo ip addr add 192.168.70.151/255.255.255.0 broadcast 192.168.70.255 dev ens33

ACCOUNT=`cat /home/mdulatov/scripts/.my.cnf`
REPL=`cat /home/mdulatov/scripts/.repl.cnf`
# Настройка Slave хоста
echo "Этот хост называется:";
hostname
hostname > /home/mdulatov/hostname
SLAVE=`cat /home/mdulatov/hostname`
if [ "$SLAVE" == "mysql-master" ]; then
echo "Этот скрипт предназначен для SLAVE хоста" 
echo "Нужно переименовать и перегрузить? Y/N"
read RENYES
   if [ ${RENYES^^} == "Y" ]; then
    #удаляем на hostname mysql-slave
    rm -f /var/lib/mysql/auto.cnf
    #увеличиваем server_id = 2
    #nano /etc/my.cnf
    # или двухстрочным скриптом
    rpl "[mysqld]" "[mysqld]
    server_id = 2" /etc/my.cnf
    #рестарт после перименования
    sudo hostnamectl set-hostname mysql-slave
    sudo reboot
    echo "Перегружаемся";
   fi
else
echo "Введите IP мастер хоста";
read MASTERIP
echo "Введите с мастера файл binlog.0000xx";
read BINLOG
echo "Введите MASTER_LOG_POS";
read LOGPOS
echo "C мастер хоста используйте файл binlog.000xx и позиции Position";
echo -en "\033[36;1;5m После подключения к MySQL выполните следующие комманды:\033[0m \n";
echo -en "\033[36;1;5m Внимание отредактируйте под сои нужды\033[0m \n";
echo -en "\033[36;1;5m STOP SLAVE; \033[0m \n";
echo "Следующую длинную строку введите в одну строку";
echo -en "\033[36;1;5m CHANGE MASTER TO MASTER_HOST='$MASTERIP',MASTER_USER='repl',MASTER_PASSWORD='$REPL',MASTER_LOG_FILE='$BINLOG',MASTER_LOG_POS=$LOGPOS,GET_MASTER_PUBLIC_KEY=1; \033[0m \n";
echo -en "\033[36;1;5m  START SLAVE; \033[0m \n";
echo -en "\033[36;1;5m  SHOW SLAVE STATUS\G \033[0m \n";
echo -en "\033[36;1;5m  SHOW VARIABLES LIKE '%relay%'; \033[0m \n";
echo "Для подключения используйте пароль $ACCOUNT";
echo "и команду: mysql -uroot -p";
read CMDMSQL
$CMDMSQL
fi
