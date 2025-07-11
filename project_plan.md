# **Project Plan: Inception**

## **I. General Guidelines**

1. **Environment**: Complete the project on a Virtual Machine.  
2. **File Structure**:  
   * Place all configuration files in a srcs/ directory.  
   * Create a Makefile at the root of the project.  
3. **Automation**: The Makefile must build and launch the entire application using docker-compose.yml.

## **II. Mandatory Part**

1. **Infrastructure Setup**:  
   * Use Docker Compose to orchestrate the services.  
   * Each service must run in a dedicated container.  
   * Build Docker images from either the penultimate stable version of Alpine or Debian.  
   * Write a separate Dockerfile for each service.  
   * Do not use pre-built images from DockerHub (except for the base OS).  
2. **Services**:  
   * **NGINX**: A container running NGINX with TLSv1.2 or TLSv1.3 enabled. This will be the sole entry point to the infrastructure on port 443\.  
   * **WordPress**: A container with WordPress and php-fpm.  
   * **MariaDB**: A container running the MariaDB database.  
3. **Data and Networking**:  
   * **Volume 1**: A Docker volume for the WordPress database.  
   * **Volume 2**: A Docker volume for the WordPress website files.  
   * **Network**: A dedicated Docker network to connect the containers.  
   * The host machine's /home/login/data directory should be used for the volumes.  
4. **Configuration & Security**:  
   * Containers must restart automatically on crash.  
   * Configure a domain name (login.42.fr) to point to your local IP.  
   * Do not use the :latest tag for Docker images.  
   * Store passwords and other secrets securely using environment variables (.env file) and Docker secrets, not in the Dockerfile.  
   * Create two users in the WordPress database, including an administrator with a non-standard username.

## **III. Submission**

* Submit the project to your Git repository.  
* Ensure all folder and file names are correct.