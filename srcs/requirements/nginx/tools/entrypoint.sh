#!/bin/bash

# The path to the NGINX config file
CONFIG_FILE="/etc/nginx/conf.d/default.conf"

# Substitute the placeholder with the environment variable
# This ensures NGINX uses the correct domain name from the .env file
sed -i "s/__DOMAIN_NAME__/${DOMAIN_NAME}/g" ${CONFIG_FILE}

echo "NGINX configuration updated with domain: ${DOMAIN_NAME}"

# Start NGINX in the foreground
exec nginx -g 'daemon off;' 