#!/bin/bash
## Установка Wordpress
# скачиваем на mysql-master
wget https://ru.wordpress.org/wordpress-4.4.29-ru_RU.zip
sudo unzip -d /var/www/html wordpress-4.4.29-ru_RU.zip
touch /var/www/html/wordpress/wp-config.php
sudo chmod -R 775 /var/www/html/wordpress/wp-config.php
sudo chmod -R 775 /var/www/html
# Создаём пользователя для joomla
ACCOUNT=`cat /home/mdulatov/scripts/.my.cnf`
echo " Пароль для подключения $ACCOUNT";
echo "Для создания базы и пользователя используйте следующие команды";
echo "CREATE DATABASE wordpress; use mysql; CREATE USER wordpress@'%' IDENTIFIED WITH mysql_native_password BY 'AmanAzamat20@@'; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%'; FLUSH PRIVILEGES; EXIT; ";
echo "mysql -uroot -p";
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

