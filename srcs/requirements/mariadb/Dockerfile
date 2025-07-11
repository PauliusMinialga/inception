# Dockerfile for MariaDB Service
FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy the database initialization script from the tools directory
COPY ./tools/initial_db.sh /usr/local/bin/initial_db.sh
RUN chmod +x /usr/local/bin/initial_db.sh

EXPOSE 3306

# Set the entrypoint to our initialization script
ENTRYPOINT ["/usr/local/bin/initial_db.sh"] 