#!/bin/bash

#########################################################################

# updating and upgrading the server

sudo apt update && sudo apt upgrade -y

#########################################################################

#########################################################################


# Install Apache 

######################################################################### 

sudo apt-get install apache2 -y < /dev/null

sudo apt-get install mysql-server -y < /dev/null

sudo add-apt-repository -y ppa:ondrej/php < /dev/null

sudo apt-get update < /dev/null

sudo apt-get install libapache2-mod-php php php-common php-xml php-mysql php-gd php-mbstring php-tokenizer php-json php-bcmath php-curl php-zip unzip -y < /dev/null

sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini

sudo systemctl restart apache2 < /dev/null

#########################################################################

#########################################################################

# Install Composer

########################################################################

sudo apt install curl -y 

sudo curl -sS https://getcomposer.org/installer | php 

sudo mv composer.phar /usr/local/bin/composer 

composer --version < /dev/null

#######################################################################



#########################################################################

#########################################################################

# Clone Laravel Project and dependencies

#########################################################################

mkdir /var/www/html/laravel && cd /var/www/html/laravel

cd /var/www/html && sudo git clone https://github.com/laravel/laravel

cd /var/www/html/laravel && composer install --no-dev < /dev/null

sudo chown -R www-data:www-data /var/www/html/laravel

sudo chmod -R 775 /var/www/html/laravel

sudo chmod -R 775 /var/www/html/laravel/storage

sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache

cd /var/www/html/laravel && sudo cp .env.example .env

php artisan key:generate


#########################################################################

#########################################################################

#configuring Apache for Laravel

#########################################################################

cat << EOF > /etc/apache2/sites-available/laravel.conf
<VirtualHost *:80>
    ServerAdmin admin@example.com
    ServerName  192.168.20.11
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
    Options Indexes MultiViews FollowSymLinks
    AllowOverride All
    Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo a2enmod rewrite

sudo a2ensite laravel.conf

sudo systemctl restart apache2 

#########################################################################


#########################################################################

# Configuring MySQL for Laravel

#########################################################################

echo "creating MySQL database for Laravel"
PASS=$2
if [ -z "$2" ]; then
    PASS=`openssl rand -base64 8`
fi

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE $1;
CREATE USER '$1'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
echo "Username:   $1"
echo "Password:   $PASS"

#########################################################################

#########################################################################

# execute key generate and migrate command for Laravel

#########################################################################


sudo sed -i 's/DB_DATABASE=laravel/DB_DATABASE=adams/' /var/www/html/laravel/.env

sudo sed -i 's/DB_USERNAME=root/DB_USERNAME=adams/' /var/www/html/laravel/.env

sudo sed -i 's/DB_PASSWORD=/DB_PASSWORD=246810/' /var/www/html/laravel/.env

php artisan config:cache

cd /var/www/html/laravel && php artisan migrate