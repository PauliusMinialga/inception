#!/bin/bash

set -e

echo "Starting MariaDB initialization..."

# Ensure critical directories exist and have correct permissions
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Check if we need to initialize
NEED_INIT=false

if [ ! -d "/var/lib/mysql/mysql" ]; then
    NEED_INIT=true
    echo "MariaDB data directory not found. Full initialization needed."
elif [ ! -f "/var/lib/mysql/.initialization_complete" ]; then
    NEED_INIT=true
    echo "MariaDB initialization incomplete. Re-initializing."
fi

if [ "$NEED_INIT" = true ]; then
    echo "Initializing MariaDB..."
    
    # Read secrets
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    DB_PASSWORD=$(cat /run/secrets/db_password)

    # Remove any corrupted data
    rm -rf /var/lib/mysql/*
    
    # Fresh initialization
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start temporary server
    echo "Starting temporary MariaDB server..."
    /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    pid="$!"

    # Wait for server to be ready
    echo "Waiting for temporary server..."
    until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
        sleep 2
    done

    echo "Configuring database..."

    # Configure database (using socket connection, no password needed initially)
    mysql --socket=/var/run/mysqld/mysqld.sock -u root <<-EOF
		-- Set root password
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		
		-- Remove anonymous users
		DELETE FROM mysql.user WHERE User='';
		
		-- Remove remote root access
		DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
		
		-- Remove test database
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
		
		-- Create WordPress database
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
		
		-- Create WordPress users
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		CREATE USER IF NOT EXISTS '${DB_USER}'@'wordpress' IDENTIFIED BY '${DB_PASSWORD}';
		CREATE USER IF NOT EXISTS '${DB_USER}'@'wordpress.srcs_inception' IDENTIFIED BY '${DB_PASSWORD}';
		
		-- Grant permissions
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'wordpress';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'wordpress.srcs_inception';
		
		-- Apply changes
		FLUSH PRIVILEGES;
EOF

    echo "Database configuration complete. Stopping temporary server..."

    # Stop temporary server
    mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait $pid 2>/dev/null || true

    # Mark initialization as complete
    touch /var/lib/mysql/.initialization_complete
    
    echo "MariaDB initialization complete."
else
    echo "MariaDB already initialized. Starting normally."
fi

echo "Starting MariaDB in normal mode..."
exec /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
