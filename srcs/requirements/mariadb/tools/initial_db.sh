#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Ensure critical directories exist and have correct permissions.
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Only initialize the database on the first run.
if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
    echo "MariaDB data directory not found. Initializing database..."

    # Read secrets
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    DB_PASSWORD=$(cat /run/secrets/db_password)

    # Initialize the database directory structure
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start a temporary server in the background using the correct path
    /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking --nowatch &
    pid="$!"

    # Wait for the server to be ready
    until mysqladmin ping --silent; do
        echo "Waiting for temporary MariaDB server..."
        sleep 2
    done

    # Run setup SQL
    mysql -u root <<-EOF
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
        FLUSH PRIVILEGES;
EOF

    # Shutdown the temporary server safely
    if ! mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown; then
      echo "MariaDB shutdown failed. Killing process..." >&2
      kill -9 "$pid"
    fi
    
    echo "Database initialization complete."
fi

echo "Starting MariaDB in normal mode..."
# Execute the final server process using the correct path
exec /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql
