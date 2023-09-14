#!/bin/bash

[ $(id -u) -gt 0 ] && echo «Пожалуйста, выполните этот сценарий от имени пользователя root!» && exit 1
sysversion=$(rpm -q centos-release|cut -d- -f3)

echo "Выберите номер команды";
echo "1. Просмотр процессов, с последующим поиском stroka: ps -elf | grep stroka";
echo "2. Просмтор открытых файлов, с последующим поиском: find /proc/[0-9]*/fd -type l -exec ls -l {} \; | grep stroka_PID";
echo "3. Повышение приоритета процесса на 10, с выбором PID: renice -n -10 -p stroka_PID":
echo "4. Понижение приоритета процесса на 10, с выбором PID: renice -n 10 -p stroka_PID";
echo "5. Выход";

read commline;

if [ "$commline" == "1" ]; then
ps -elf 
echo "Введите что ищем";
read stroka
ps -elf | grep $stroka
echo "Введите номер команды";
read commline
fi
if [ "$commline" == "2" ]; then
find /proc/[0-9]*/fd -type l -exec ls -l {} \;
echo "Введите, что ищем";
read stroka
find /proc/[0-9]*/fd -type l -exec ls -l {} \; | grep $stroka_PID;
echo "Введите номер команды";
read commline
fi
if [ "$commline" == "3" ]; then
top -n 2
echo "Введите номер процессам PID для повышения приоритета";
read stroka_PID
renice -n -10 -p $stroka_PID
echo "Введите номер команды";
top -n 1
read commline
fi
if [ "$commline" == "4" ]; then
top -n 2
echo "Введите номер процессам PID для повышения приоритета";
read stroka_PID
renice -n -10 p $stroka_PID
top -n 1
echo "Введите номер команды";
read commline
fi
if [ "$commlin" == "5" ]; then
echo "Спасибо, досвидания!";
fi


