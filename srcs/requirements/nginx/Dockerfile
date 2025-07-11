# Dockerfile for NGINX Service
FROM debian:bullseye

# Install NGINX and OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Create directories for TLS certificate
RUN mkdir -p /etc/nginx/tls

# Copy the script to generate TLS certs
COPY ./tools/generate_tls.sh /usr/local/bin/generate_tls.sh
RUN chmod +x /usr/local/bin/generate_tls.sh

# Generate the self-signed certificate during the build
# This uses the DOMAIN_NAME from the .env file, passed as a build argument
ARG DOMAIN_NAME
RUN /usr/local/bin/generate_tls.sh ${DOMAIN_NAME}

# Copy the NGINX configuration file
COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the entrypoint script
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

# Set the entrypoint to our new script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 