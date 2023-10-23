---

- hosts: all
  become: yes
  pre_tasks:

  - name: update & upgrade server
    apt:
      update_cache: yes
      upgrade: yes

  - name: set cron job to check uptime of the server every 12 am
    cron:
      name: set cron job to check uptime of the server every 12 am
      minute: "0"
      hour: "0"
      day: "*"
      month: "*"
      weekday: "*"
      job: "/usr/bin/uptime > /var/log/uptime_check.log 2>&1"
      state: present

  - name: copy the bash script to slave machine
    copy:
      src: laravel_script.sh
      dest: ~/
      owner: root
      group: root
      mode: 0744

  - name: Set Execute Permissions on the Script
    command: chmod +x ~/laravel_script.sh


- hosts: target_servers
  become: yes
  tasks:
    - name: Run Bash Script
      shell: |
        #!/bin/bash
        #########################################################
        # updating and upgrading the server
        #########################################################
        sudo apt update && sudo apt upgrade -y < /dev/null
        #########################################################
        # Install Apache, MySQL, PHP (LAMP) Stack on Ubuntu 20.04
        #########################################################
        sudo apt-get install apache2 -y < /dev/null
        sudo apt-get install mysql-server -y < /dev/null
        sudo add-apt-repository -y ppa:ondrej/php < /dev/null
        sudo apt-get update < /dev/null
        sudo apt-get install libapache2-mod-php php php-common php-xml php-mysql php-gd php-mbstring php-tokenizer php-json php-bcmath php-curl php-zip unzip -y < /dev/null
        sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini
        sudo systemctl restart apache2 < /dev/null
        #########################################################
        # Install Composer
        #########################################################
        sudo apt install curl -y
        sudo curl -sS https://getcomposer.org/installer | php
        sudo mv composer.phar /usr/local/bin/composer
        composer --version < /dev/null
        #########################################################
        # Configuring Apache for Laravel
        #########################################################
        cat << EOF > /etc/apache2/sites-available/laravel.conf
        <VirtualHost *:80>
            ServerAdmin admin@example.com
            ServerName 192.168.50.11
            DocumentRoot /var/www/html/laravel/public
            <Directory /var/www/html/laravel>
            Options Indexes MultiViews FollowSymLinks
            AllowOverride All
            Require all granted
            </Directory>
            ErrorLog \${APACHE_LOG_DIR}/error.log
            CustomLog \${APACHE_LOG_DIR}/access.log combined
        </VirtualHost>
        EOF
        sudo a2enmod rewrite
        sudo a2ensite laravel.conf
        sudo systemctl restart apache2
        #########################################################
        # Clone Laravel Project and dependencies
        #########################################################
        mkdir /var/www/html/laravel && cd /var/www/html/laravel
        cd /var/www/html && sudo git clone https://github.com/laravel/laravel
        cd /var/www/html/laravel && composer install --no-dev < /dev/null
        sudo chown -R www-data:www-data /var/www/html/laravel
        sudo chmod -R 775 /var/www/html/laravel
        sudo chmod -R 775 /var/www/html/laravel/storage
        sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache
        cd /var/www/html/laravel && sudo cp .env.example .env
        php artisan key:generate
        #########################################################
        # Configuring MySQL for Laravel
        #########################################################
        echo "Creating MySQL user and database"
        PASS=$2
        if [ -z "$2" ]; then
          PASS=\`openssl rand -base64 8\`
        fi
        mysql -u root <<MYSQL_SCRIPT
        CREATE DATABASE $1;
        CREATE USER '$1'@'localhost' IDENTIFIED BY '\$PASS';
        GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';
        FLUSH PRIVILEGES;
        MYSQL_SCRIPT
        echo "MySQL
