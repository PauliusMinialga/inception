#!/bin/bash

# Define paths to the secret files
DB_PASSWORD_FILE=/run/secrets/db_password
WP_ADMIN_PASSWORD_FILE=/run/secrets/wp_admin_password
WP_USER_PASSWORD_FILE=/run/secrets/wp_user_password

# Wait for the database service to be available
while ! mysqladmin ping -h"mariadb" -u"${DB_USER}" -p"$(cat $DB_PASSWORD_FILE)" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# Change to the WordPress directory
cd /var/www/html

# If wp-config.php doesn't exist, it means WordPress is not installed yet
if [ ! -f "wp-config.php" ]; then
    echo "Configuring WordPress..."

    # Read secrets into variables
    DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
    WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
    WP_USER_PASSWORD=$(cat "$WP_USER_PASSWORD_FILE")

    # Download WordPress core files
    wp core download --allow-root

    # Create wp-config.php
    wp config create --dbname=${DB_NAME} \
                     --dbuser=${DB_USER} \
                     --dbpass=${DB_PASSWORD} \
                     --dbhost=mariadb \
                     --allow-root

    # Install WordPress, creating the admin user
    wp core install --url=${DOMAIN_NAME} \
                    --title="Inception" \
                    --admin_user=${WP_ADMIN_USER} \
                    --admin_password=${WP_ADMIN_PASSWORD} \
                    --admin_email=${WP_ADMIN_EMAIL} \
                    --skip-email \
                    --allow-root

    # Create the second, non-admin user
    wp user create ${WP_USER_USER} ${WP_USER_EMAIL} \
                   --role=author \
                   --user_pass=${WP_USER_PASSWORD} \
                   --allow-root
fi

echo "WordPress is ready. Starting PHP-FPM..."

# Start the PHP-FPM service in the foreground
# Use version 7.4, which is standard for Debian Bullseye
exec /usr/sbin/php-fpm7.4 -F 