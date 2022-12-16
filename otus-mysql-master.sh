#!/bin/bash
[ $(id -u) -gt 0 ] && echo «Пожалуйста, выполните этот сценарий под sudo!» && exit 1
sysversion=$(rpm -q centos-release|cut -d- -f3) 

# Настройка мастер хоста
ACCOUNT=`cat /home/mdulatov/scripts/.my.cnf`
echo "Для просмотрта статуса мастера, его файла binlog.000xx и позиции Position";
echo "После подключения к MySQL выполните следующие комманды:";
echo -en "\033[36;1;5m Внимание \033[0m  ";
echo -en "\033[36;1;5m use mysql; SHOW MASTER STATUS; EXIT; \033[0m \n";
echo "Для подключения используйте пароль $ACCOUNT";
echo "и команду: mysql -uroot -p";
read CMDMSQL
$CMDMSQL
echo "!! Внимание !!!";
echo "Вывод IP нужен на Slave хосте";
ip -c a | grep "192.168."
