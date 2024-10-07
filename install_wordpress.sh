#!/bin/bash

# chmod +x install_wordpress.sh
# ./install_wordpress.sh

# === Configuration ===
# === Should be changed ===
DB_NAME="wordpress_db"      # Database name
DB_USER="wp_user"           # Database username
DB_PASSWORD="wp_password"   # Password for the database user
DB_ROOT_PASSWORD="root_password" # MySQL root password
WP_URL="http://localhost"   # WordPress site URL
WP_TITLE="My WordPress Site" # Site title
WP_ADMIN_USER="admin"       # WordPress admin username
WP_ADMIN_PASSWORD="admin_password" # WordPress admin password
WP_ADMIN_EMAIL="admin@example.com" # WordPress admin email

# === Update packages and install dependencies ===
sudo apt update
sudo apt upgrade -y

# Install Apache, MySQL, and PHP
sudo apt install apache2 mysql-server php php-mysql libapache2-mod-php php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip unzip -y

# === MySQL Setup ===
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$DB_ROOT_PASSWORD';"
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "CREATE DATABASE $DB_NAME;"
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

# === WordPress Installation ===
cd /var/www/html
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* .
sudo rm -rf wordpress latest.zip
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# === Configure wp-config.php ===
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php

# Generate unique keys and salts
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo sed -i "/AUTH_KEY/s/put your unique phrase here/$SALT/" wp-config.php

# === Apache Configuration ===
sudo a2enmod rewrite
sudo systemctl restart apache2

# === Install WP-CLI for automated setup ===
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# === Final WordPress Setup via WP-CLI ===
wp core install --url=$WP_URL --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --path=/var/www/html --allow-root

echo "WordPress installation completed!"
echo "Site URL: $WP_URL"
echo "Admin login: $WP_ADMIN_USER"
