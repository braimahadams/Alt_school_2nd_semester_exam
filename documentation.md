# Project Documentation


## Introduction

This documentation provides an overview of the project, which involves automating the provisioning of two Ubuntu-based servers using Vagrant. The Master server deploys a LAMP (Linux, Apache, MySQL, PHP) stack, while the Slave server executes a Bash script via Ansible and checks server uptime with a cron job.

## Repository Overview

### Laravel

The Laravel application is a PHP-based web application. It's a sample application that demonstrates the project's functionality.

### LAMP Stack

The LAMP stack consists of Linux (Ubuntu), Apache web server, MySQL database, and PHP. This stack serves as the foundation for the Laravel application.

### Master and Slave Nodes

- **Master**: This server hosts the LAMP stack and deploys the Laravel application.
- **Slave**: This server runs Ansible to execute tasks on the Master node and checks server uptime using a cron job.


## Repository Structure

### ansible.cfg

The `ansible.cfg` file is the Ansible configuration file. It sets various options and parameters for Ansible, like specifying the inventory file location.

### inventory.ini

The `inventory.ini` file defines the hosts (Master and Slave) and their connection details for Ansible. This is where you specify the target servers.

### playbook.yml

The `playbook.yml` file is the Ansible playbook. It defines the tasks to be executed on the Slave server, which includes running the `laravel_script.sh` script on the Master server.

### laravel_script.sh

The `laravel_script.sh` script is used for provisioning the Master node. It installs the LAMP stack, clones the Laravel application from GitHub, configures Apache and MySQL, and more.

## How to Run the Repository

### .env

To configure the Laravel application:
1. Open the `.env` file.
2. Modify the username, database name, and password to match your requirements.

### MySQL

To execute the MySQL script:
1. Run `./laravel_script.sh adams 246810`. Replace "adams" with your desired database name and "246810" with your preferred password.

### Ansible Configuration

To configure Ansible for the project:
1. Update the `server_name` in the `ansible.cfg` file to match your server's IP address.

## Screenshots

- The Laravel application is accessible via the VM's IP address on the Slave node. i uploaded a screenshot as evidence in my files

