# Makefile for the Inception Project

COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env

# Create required directories
setup:
	@echo "Creating required directories..."
	@mkdir -p $(HOME)/data/mariadb
	@mkdir -p $(HOME)/data/wordpress
	@echo "Data directories created successfully."

# Build all service images
all:
	@echo "Building all service images..."
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build

# Start all services in detached mode
up: setup all
	@echo "Starting all services..."
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d

# Stop all running services
down:
	@echo "Stopping all services..."
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down

# Stop services and remove all related data
clean: down
	@echo "Cleaning up the project..."
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down --rmi all -v
	@echo "Removing data directories..."
	@sudo rm -rf $(HOME)/data/mariadb $(HOME)/data/wordpress || true
	@echo "Cleanup complete."

# Rebuild and restart the entire project
re: clean up
	@echo "Project has been rebuilt."

# Show status of all containers
status:
	@echo "Container status:"
	@docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) ps

# Show logs for all services
logs:
	@docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

# Show logs for a specific service (usage: make logs-mariadb)
logs-%:
	@docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f $*

.PHONY: setup all up down clean re status logs
