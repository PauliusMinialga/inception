#!/bin/bash

# Define paths to the secret files
DB_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
DB_PASSWORD_FILE=/run/secrets/db_password

# Check if secrets are mounted
if [ ! -f "$DB_ROOT_PASSWORD_FILE" ] || [ ! -f "$DB_PASSWORD_FILE" ]; then
    echo "Error: Database secret files not found."
    exit 1
fi

# Read passwords from the secret files
DB_ROOT_PASSWORD=$(cat "$DB_ROOT_PASSWORD_FILE")
DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")

# Start MariaDB in the background
/usr/bin/mysqld_safe --datadir=/var/lib/mysql &

# Wait for MariaDB to start
while ! mysqladmin ping -h'localhost' --silent; do
    echo "Waiting for MariaDB to be up..."
    sleep 1
done

# Execute SQL setup commands
mysql -u root <<-EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS ${DB_NAME};
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
    FLUSH PRIVILEGES;
EOF

# Shut down the temporary MariaDB instance
mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

# Restart MariaDB in the foreground
exec /usr/bin/mysqld_safe --datadir=/var/lib/mysql 