#!/bin/bash

# Check if a domain name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain_name>"
    exit 1
fi

DOMAIN_NAME=$1
CERT_DIR="/etc/nginx/tls"
KEY_FILE="${CERT_DIR}/${DOMAIN_NAME}.key"
CERT_FILE="${CERT_DIR}/${DOMAIN_NAME}.crt"

echo "Generating TLS certificate for ${DOMAIN_NAME}..."

# Generate a private key and a self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${KEY_FILE}" \
    -out "${CERT_FILE}" \
    -subj "/C=US/ST=California/L=Fremont/O=42/OU=student/CN=${DOMAIN_NAME}"

echo "TLS certificate and key created:"
echo "Key: ${KEY_FILE}"
echo "Cert: ${CERT_FILE}" 