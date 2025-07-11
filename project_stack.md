# **Project Stack: Inception**

## **Core Technologies**

* **Virtualization**: The entire project must be run within a **Virtual Machine**.  
* **Containerization**: **Docker** is the core technology for creating and managing containers.  
* **Orchestration**: **Docker Compose** is used to define and run the multi-container application.

## **Services**

* **Web Server**: **NGINX**  
  * **Protocol**: Must be configured to use TLSv1.2 or TLSv1.3 for secure communication.  
* **Content Management System (CMS)**: **WordPress**  
  * **PHP Processor**: php-fpm is required for processing PHP scripts.  
* **Database**: **MariaDB** (a fork of MySQL).

## **Operating System Base**

* **Container Base Image**: All Docker images must be built on either **Alpine Linux** (penultimate stable version) or **Debian** (penultimate stable version).

## **Configuration and Automation**

* **Build Automation**: A Makefile is required to automate the building and execution of the Docker Compose setup.  
* **Environment Variables**: A .env file must be used to manage environment-specific variables, such as domain names and credentials.  
* **Secrets Management**: Docker secrets are recommended for handling sensitive information like database passwords.