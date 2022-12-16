#!/bin/bash

[ $(id -u) -gt 0 ] && echo «Пожалуйста, выполните этот сценарий под sudo!» && exit 1
sysversion=$(rpm -q centos-release|cut -d- -f3) 

yum install -y rpm yum-utils 
yum check-update
#убираем запрос пароля для sudo
echo "mdulatov    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
#установка пакетов
yum install -y epel-release
yum install -y nginx httpd 
yum install -y wget nano unzip mc 
yum install -y php php-common php-gd php-mysql php-xml php-mbstring php-fpm
yum install -y rsync rpl bzip2 unzip pwgen git

# Автозапуск Apache
rpl "Listen 80" "Listen 8080" /etc/httpd/conf/httpd.conf
rpl "DirectoryIndex index.html" "DirectoryIndex index.html index.php" /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd

# Автозапуск Nginx
systemctl start nginx
systemctl enable nginx

# Отключаем firewalld
systemctl stop firewalld
systemctl disable firewalld

# установка мониторинга

mkdir /etc/prometheus
mkdir /var/lib/prometheus
cd /etc/prometheus
if [ -e prometheus-2.39.1.linux-amd64.tar.gz ]
then tar - xf prometheus-2.39.1.linux-amd64.tar.gz
cd prometheus-2.39.1.linux-amd64
cp prometheus promtool /usr/local/bin/
cp -r console_libraries consoles prometheus.yml /etc/prometheus
useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
else
wget https://github.com/prometheus/prometheus/releases/download/v2.39.1/prometheus-2.39.1.linux-amd64.tar.gz
tar -xf prometheus-2.39.1.linux-amd64.tar.gz
cd prometheus-2.39.1.linux-amd64
cp prometheus promtool /usr/local/bin/
cp -r console_libraries consoles prometheus.yml /etc/prometheus
useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
fi

mkdir -p /opt/node_exporter
curl -LO "https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz"
tar -xvzf ~/node_exporter-1.4.0.linux-amd64.tar.gz && cp ~/node_exporter-1.4.0.linux-amd64/node_exporter /opt/node_exporter
touch /etc/systemd/system/node_exporter.service

echo "[Unit]
Description=Node Exporter

[Service]
ExecStart=/opt/node_exporter/node_exporter

[Install]
WantedBy=default.target" >> /etc/systemd/system/node_exporter.service


# Устанавливаем MySQL
#rpm -e mysql80-community-release-el7-3.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
yum --enablerepo=mysql80-community install -y mysql-community-server

mkdir /home/mdulatov/scripts
touch /home/mdulatov/scripts/.my.cnf
cp /home/mdulatov/scripts/.my.cnf /home/mdulatov/scripts/.my.$(date +%Y-%m-%d).cnf
pwgen 14 1 -n 2 -y -s hard-to-memorize passwords > /home/mdulatov/scripts/.my.cnf
chmod 600 /home/mdulatov/scripts/.my.cnf
ACCOUNT=`cat /home/mdulatov/scripts/.my.cnf`
#Создаем строку подключения
touch /home/mdulatov/.my.cnf
echo "-uroot -p$ACCOUNT" > /home/mdulatov/.my.cnf
MYCONN=`cat /home/mdulatov/.my.cnf`

touch /home/mdulatov/scripts/.repl.cnf
cp /home/mdulatov/scripts/.repl.cnf /home/mdulatov/scripts/.repl.$(date +%Y-%m-%d-%T).cnf
pwgen 14 1 -n 2 -y -s hard-to-memorize passwords > /home/mdulatov/scripts/.repl.cnf
chmod 600 /home/mdulatov/scripts/.repl.cnf
REPLPSW=`cat /home/mdulatov/scripts/.repl.cnf`
echo "-urepl -p$REPLPSW" > /home/mdulatov/.repl.cnf
MYCONN=`cat /home/mdulatov/.my.cnf`
sudo chmod 600 *.cnf

# Ставим в автозагрузку
systemctl start mysqld
systemctl enable mysqld

#Выясняем временный пароль
echo "    Нужно сменить временный пароль для root, это можно сделать только в коммандной строке";
#Меняем пароль root. Созадаем пользователя для репликации
echo "    Cледующые команды, для смены пароля root (пароль сохранен в scripts/.my.cnf)";
echo -en "\033[36;1;5m ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$ACCOUNT'; \033[0m \n";
echo "    Создание пользователя для репликации  ";
echo -en "\033[36;1;5m use mysql; CREATE USER repl@'%' IDENTIFIED WITH mysql_native_password BY '$REPLPSW'; GRANT REPLICATION SLAVE ON *.* TO repl@'%'; FLUSH PRIVILEGES;EXIT; \033[0m \n";
echo "";
echo "Для подключения используйте коммандную строку ниже, затем временный пароль. Не забудьте сменить пароль верхней строкой";
grep "A temporary password" /var/log/mysqld.log
echo "Найдите временный пароль вверху используйте в строке ниже, введите ее";
echo "mysql -uroot -p";
read CHMSPSWD
sudo $CHMSPSWD
echo -en "\033[36;1;5m Пользователь создан repl@'%' c паролем $REPLPSW находиться в домашней диретории .repl.cnf \033[0m \n";

#Ставим имя хоста
echo "Хост будет переименован в mysql-master";
sudo hostnamectl set-hostname mysql-master
echo -en "\033[36;1;5m  Выключите для клонирования коммандой: sudo shutdown   \033[0m \n";
