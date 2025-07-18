# Dockerfile for MariaDB Service
FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Directly modify the default config to allow external connections
RUN sed -i "s/^\s*bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the database initialization script from the tools directory
COPY ./tools/initial_db.sh /usr/local/bin/initial_db.sh
RUN chmod +x /usr/local/bin/initial_db.sh

EXPOSE 3306

# Set the entrypoint to our initialization script
ENTRYPOINT ["/usr/local/bin/initial_db.sh"]
