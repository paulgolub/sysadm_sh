#!/bin/bash

# chmod +x remove_wordpress.sh
# ./remove_wordpress.sh

# Set variables
WP_PATH="/var/www/html"          # Path to WordPress installation
DB_NAME="wordpress_db"           # Name of the WordPress database
DB_USER="wp_user"                # Database user name
DB_PASS="wp_password"            # Database user password

# Remove WordPress files
echo "Removing WordPress files..."
if [ -d "$WP_PATH" ]; then
    rm -rf "$WP_PATH"
    echo "WordPress removed from $WP_PATH."
else
    echo "WordPress installation not found at $WP_PATH."
fi

# Remove database
echo "Removing database $DB_NAME..."
mysql -u "$DB_USER" -p"$DB_PASS" -e "DROP DATABASE $DB_NAME;"
if [ $? -eq 0 ]; then
    echo "Database $DB_NAME removed."
else
    echo "Failed to remove database $DB_NAME."
fi

# Remove database user (if required)
echo "Removing database user $DB_USER..."
mysql -u "$DB_USER" -p"$DB_PASS" -e "DROP USER '$DB_USER'@'localhost';"
if [ $? -eq 0 ]; then
    echo "User $DB_USER removed."
else
    echo "Failed to remove database user $DB_USER."
fi

# Remove configuration files (if any)
echo "Removing configuration files..."
CONFIG_FILES=("/etc/php/7.x/fpm/php.ini" "/etc/nginx/sites-available/default") # Specify necessary configs
for FILE in "${CONFIG_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        rm -f "$FILE"
        echo "Configuration file $FILE removed."
    else
        echo "Configuration file $FILE not found."
    fi
done

echo "Removal of WordPress and all dependencies completed."
