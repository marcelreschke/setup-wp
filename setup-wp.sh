#!/usr/bin/env bash

printf 'In which folder should we install WordPress? '
read NEWDIR
mkdir /var/www/$NEWDIR
mkdir /var/www/$NEWDIR/public_html
cd /var/www/$NEWDIR/public_html
pwd

MYSQLPASS=$(makepasswd --chars 12)
mysql -e "create database $NEWDIR;grant all privileges on $NEWDIR.* TO '$NEWDIR'@'localhost' identified by '$MYSQLPASS';flush privileges;"

wp core download --locale=de_DE --force --allow-root

wp core config --dbname=$NEWDIR --dbuser=$NEWDIR --dbpass=$MYSQLPASS --dbprefix=$NEWDIR"_" --allow-root

wpurl=$NEWDIR.herogoo.website

wp core install --url=$wpurl --title=$NEWDIR --admin_name=mreschke --admin_email=hello@marcelreschke.com --admin_password=$MYSQLPASS --allow-root
wp option update permalink_structure /%postname%/ --allow-root

find . -exec chown www-data:www-data {} \;

cat <<EOF >/etc/nginx/sites-available/$NEWDIR
server {
        listen 80;

        root /var/www/$NEWDIR/public_html;
        index index.html index.htm index.php;

        # Make site accessible from http://localhost/
        server_name $wpurl;
        include hhvm.conf;

        location / {
                try_files \$uri \$uri/ /index.php?\$args;
        }
}
EOF

ln -s /etc/nginx/sites-available/$NEWDIR /etc/nginx/sites-enabled/$NEWDIR
service nginx restart

printf "Access Data for http://$wpurl\n"
printf "Username: mreschke\n"
printf "Pass: $MYSQLPASS\n"
