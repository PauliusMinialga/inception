#!/bin/bash

# Define paths to the secret files
DB_PASSWORD_FILE=/run/secrets/db_password
WP_ADMIN_PASSWORD_FILE=/run/secrets/wp_admin_password
WP_USER_PASSWORD_FILE=/run/secrets/wp_user_password

# Wait for the database service to be available
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"mariadb" -u"${DB_USER}" -p"$(cat $DB_PASSWORD_FILE)" --silent; do
    echo "Still waiting for MariaDB..."
    sleep 3
done

echo "MariaDB is ready!"

# Change to the WordPress directory
cd /var/www/html

# Read secrets into variables
DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
WP_USER_PASSWORD=$(cat "$WP_USER_PASSWORD_FILE")

# Check if WordPress is already installed
if [ ! -f "wp-config.php" ]; then
    echo "Configuring WordPress..."
    
    # Download WordPress core files only if they don't exist
    if [ ! -f "wp-settings.php" ]; then
        wp core download --allow-root
    fi

    # Create wp-config.php
    wp config create --dbname=${DB_NAME} \
                     --dbuser=${DB_USER} \
                     --dbpass=${DB_PASSWORD} \
                     --dbhost=mariadb:3306 \
                     --allow-root

    # Install WordPress
    wp core install --url=${DOMAIN_NAME} \
                    --title="Inception" \
                    --admin_user=${WP_ADMIN_USER} \
                    --admin_password=${WP_ADMIN_PASSWORD} \
                    --admin_email=${WP_ADMIN_EMAIL} \
                    --skip-email \
                    --allow-root

    # Create the second user
    wp user create ${WP_USER_USER} ${WP_USER_EMAIL} \
                   --role=author \
                   --user_pass=${WP_USER_PASSWORD} \
                   --allow-root

    echo "WordPress installation complete!"
else
    echo "WordPress already configured."
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F
