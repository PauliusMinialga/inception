# Dockerfile for WordPress Service
FROM debian:bullseye

# Install necessary packages
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql curl mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Create the WordPress directory
RUN mkdir -p /var/www/html

# Download and install wp-cli
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# Copy the configuration script
COPY ./tools/wp_config.sh /usr/local/bin/wp_config.sh
RUN chmod +x /usr/local/bin/wp_config.sh

# Create the php-fpm run directory
RUN mkdir -p /run/php

EXPOSE 9000

# Set the entrypoint to our config script
ENTRYPOINT ["/usr/local/bin/wp_config.sh"] 