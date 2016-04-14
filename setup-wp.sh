#!/usr/bin/env bash

printf 'In which folder should we install WordPress? '
read NEWDIR
mkdir $NEWDIR
cd $NEWDIR
mkdir public_html
cd public_html
pwd

MYSQLPASS=$(makepasswd --chars 12)
mysql -e "create database $NEWDIR;grant all privileges on $NEWDIR.* TO '$NEWDIR'@'localhost' identified by '$MYSQLPASS';flush privileges;"

wp core download --locale=de_DE --force --allow-root

wp core config --dbname=$NEWDIR --dbuser=$NEWDIR --dbpass=$MYSQLPASS --dbprefix=$NEWDIR"_" --allow-root

wpurl=$NEWDIR.herogoo.website

wp core install --url=$wpurl --title=$NEWDIR --admin_name=mreschke --admin_email=hello@marcelreschke.com --admin_password=$MYSQLPASS --allow-root
wp option update permalink_structure /%postname%/ --allow-root

find . -exec chown www-data:www-data {} \;
