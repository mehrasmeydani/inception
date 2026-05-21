# DEV_DOC.md - Developer Documentation

This document provides detailed instructions for developers who want to build, modify, and extend the Inception project from scratch.

---

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Prerequisites and Installation](#prerequisites-and-installation)
3. [Project Configuration](#project-configuration)
4. [Building and Launching](#building-and-launching)
5. [Docker and Container Management](#docker-and-container-management)
6. [Data Storage and Persistence](#data-storage-and-persistence)
7. [Development Workflow](#development-workflow)
8. [Debugging and Troubleshooting](#debugging-and-troubleshooting)

---

## Environment Setup

### System Requirements

- **OS**: Linux (native) or macOS with Docker Desktop or Windows with Docker Desktop + WSL2
- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum (8GB recommended)
- **Disk Space**: 10GB free (for Docker images and data)
- **Network**: Stable internet connection for initial setup

### Required Tools

All tools must be installed on your system:

```bash
# Verify installation
docker --version       # Docker Engine (v20.10+)
docker-compose --version # Docker Compose (v2.0+)
make --version        # Make (any recent version)
```

If any tool is missing, install via your package manager:

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose make
sudo usermod -aG docker $USER
newgrp docker
```

**macOS**:
```bash
brew install docker docker-compose make
# Then install Docker Desktop: https://docs.docker.com/desktop/install/mac-install/
```

**Windows (WSL2)**:
```bash
# Install Docker Desktop for Windows
# https://docs.docker.com/desktop/install/windows-install/

# Inside WSL2 terminal:
sudo apt-get update
sudo apt-get install -y make
```

---

## Prerequisites and Installation

### 1. Clone or Create Project Structure

If starting from scratch, create the directory structure:

```bash
cd ~/projects
git clone <inception-repo> inception
# Or manually create directories
mkdir -p inception/srcs/requirements/{nginx,wordpress,mariadb}
cd inception
```

### 2. Verify Project Structure

```bash
tree -L 3 inception/
# Should show:
# inception/
# ├── Makefile
# ├── README.md
# ├── USER_DOC.md
# ├── DEV_DOC.md
# └── srcs/
#     ├── docker-compose.yml
#     └── requirements/
#         ├── mariadb/
#         ├── nginx/
#         └── wordpress/
```

### 3. Create Secrets and Configuration Files

#### Create `.env` File

Create `srcs/.env` with your configuration:

```bash
cat > srcs/.env << 'EOF'
# Domain Configuration
DOMAIN_NAME=megardes.42.fr

# WordPress Configuration
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wordpress
WORDPRESS_DB_PASSWORD=wordpress_secure_password_123
WORDPRESS_TABLE_PREFIX=wp_
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=admin_secure_password_456
WORDPRESS_ADMIN_EMAIL=admin@megardes.42.fr

# MariaDB Configuration
MARIADB_ROOT_PASSWORD=root_secure_password_789
MARIADB_DATABASE=wordpress
MARIADB_USER=wordpress
MARIADB_PASSWORD=wordpress_secure_password_123

# Server Configuration
SERVER_NAME=megardes.42.fr
EOF
```

**Security Note**: 
- Replace placeholder passwords with strong, unique values
- Use at least 16 characters, mix uppercase/lowercase/numbers/special chars
- Never commit `.env` to version control
- Add `.env` to `.gitignore`:
  ```bash
  echo ".env" >> .gitignore
  ```

#### Create Data Directories

```bash
sudo mkdir -p /home/megardes/data/wordpress
sudo mkdir -p /home/megardes/data/mariadb
sudo chmod 755 /home/megardes/data/wordpress
sudo chmod 755 /home/megardes/data/mariadb
```

### 4. Update Hosts File

Add domain entry to `/etc/hosts`:

```bash
sudo grep -q "megardes.42.fr" /etc/hosts || sudo sh -c 'echo "127.0.0.1 megardes.42.fr" >> /etc/hosts'

# Verify
grep megardes.42.fr /etc/hosts
```

---

## Project Configuration

### Docker Compose Configuration

The `srcs/docker-compose.yml` defines all services. Here's the typical structure:

```yaml
version: '3.8'

services:
  nginx:
    build:
      context: requirements/nginx
      dockerfile: Dockerfile
    container_name: inception-nginx-1
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - wordpress:/var/www/wordpress
      - ./requirements/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - inception_network
    depends_on:
      - wordpress

  wordpress:
    build:
      context: requirements/wordpress
      dockerfile: Dockerfile
    container_name: inception-wordpress-1
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}
    volumes:
      - wordpress:/var/www/wordpress
    networks:
      - inception_network
    depends_on:
      - mariadb

  mariadb:
    build:
      context: requirements/mariadb
      dockerfile: Dockerfile
    container_name: inception-mariadb-1
    environment:
      MARIADB_ROOT_PASSWORD: ${MARIADB_ROOT_PASSWORD}
      MARIADB_DATABASE: ${MARIADB_DATABASE}
      MARIADB_USER: ${MARIADB_USER}
      MARIADB_PASSWORD: ${MARIADB_PASSWORD}
    volumes:
      - mariadb:/var/lib/mysql
    networks:
      - inception_network

volumes:
  wordpress:
    driver: local
  mariadb:
    driver: local

networks:
  inception_network:
    driver: bridge
```

### Dockerfile Configuration

Each service has a Dockerfile in `requirements/[service]/Dockerfile`.

**Example: Nginx Dockerfile**
```dockerfile
FROM nginx:latest

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/ssl/ /etc/nginx/ssl/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
```

**Example: WordPress Dockerfile**
```dockerfile
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/wordpress

COPY tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

EXPOSE 9000

CMD ["/tmp/setup.sh"]
```

### Configuration Files

**Nginx Configuration** (`requirements/nginx/conf/nginx.conf`):
- Defines server blocks (virtual hosts)
- Configures SSL/TLS settings
- Sets up reverse proxy to WordPress PHP-FPM container
- Port 80 → 443 redirect for HTTPS

**MariaDB Configuration** (`requirements/mariadb/conf/50-server.cnf`):
- Database server settings
- Performance tuning parameters
- Replication configuration (if needed)

### Setup Scripts

Each service may have a `tools/setup.sh` for initialization:

```bash
chmod +x requirements/[service]/tools/setup.sh
```

These scripts:
- Create necessary directories
- Initialize databases
- Download and configure applications
- Set proper permissions

---

## Building and Launching

### Build Process

The build process follows this order:

```
Dockerfiles → Images → Containers → Running Services
```

### Using Make

**Build and Launch (Recommended)**:
```bash
make
```

This:
1. Adds domain to `/etc/hosts`
2. Builds all Docker images
3. Creates containers
4. Starts all services in the custom network

**Other Make Commands**:

```bash
make help       # Show all available Makefile rules
make clean      # Stop containers (preserve data)
make good_clean # Stop and remove data
make fclean     # Stop services, remove images/volumes, and prune Docker
make purge      # Remove ALL Docker resources
make re         # Rebuild everything from scratch
```

**Status and diagnostics**:

```bash
make status         # Project-specific container/volume/network status
make list-containers
make list-images
make list-volumes
make list-networks
make list-processes
make list-logs
make list-stats
make volume-paths   # Show volume mountpoints and sizes
```

### Manual Build with Docker Compose

```bash
cd srcs

# Build images
docker-compose build

# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild specific service
docker-compose build nginx
```

### Verification After Build

```bash
# Check running containers
docker ps

# Expected output: 3 containers (nginx, wordpress, mariadb)
# CONTAINER ID  IMAGE                STATUS           NAMES
# abc123...     inception-nginx-1    Up 2 minutes     inception-nginx-1
# def456...     inception-wordpress-1  Up 2 minutes   inception-wordpress-1
# ghi789...     inception-mariadb-1  Up 2 minutes     inception-mariadb-1

# Check network
docker network ls | grep inception

# Test connectivity
docker-compose -f srcs/docker-compose.yml exec wordpress ping mariadb
```

---

## Docker and Container Management

### Essential Docker Commands

#### Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs [container_name]
docker logs -f [container_name]  # Real-time

# Execute command in container
docker exec -it [container_name] [command]
docker exec -it inception-wordpress-1 /bin/bash

# Restart container
docker restart [container_name]

# Stop container gracefully
docker stop [container_name]

# Force stop container
docker kill [container_name]

# View container processes
docker top [container_name]

# View container resource usage
docker stats [container_name]
```

#### Image Management

```bash
# List images
docker images

# View image history
docker history [image_name]

# Remove image
docker rmi [image_name]

# Build image
docker build -t [image_name]:[tag] [dockerfile_directory]

# Tag image
docker tag [source_image] [target_image]:[tag]
```

#### Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect [volume_name]

# View volume location on host
docker volume inspect inception_wordpress -f '{{.Mountpoint}}'

# Backup volume
docker run --rm -v inception_wordpress:/data -v $(pwd):/backup \
  alpine tar czf /backup/wordpress-backup.tar.gz -C /data .

# Restore volume
docker run --rm -v inception_wordpress:/data -v $(pwd):/backup \
  alpine tar xzf /backup/wordpress-backup.tar.gz -C /data

# Remove volume (WARNING: deletes data)
docker volume rm [volume_name]
```

#### Network Management

```bash
# List networks
docker network ls

# Inspect network
docker network inspect [network_name]

# Test connectivity between containers
docker exec [container1] ping [container2]
```

### Docker Compose Command Reference

```bash
cd srcs

# Build services
docker-compose build
docker-compose build nginx  # Build specific service

# Start services
docker-compose up           # Foreground
docker-compose up -d        # Background

# Stop services
docker-compose down         # Stop and remove containers
docker-compose down -v      # Stop and remove containers + volumes

# View logs
docker-compose logs         # All services
docker-compose logs -f      # Real-time
docker-compose logs nginx   # Specific service

# Execute commands
docker-compose exec [service] [command]
docker-compose exec wordpress wp plugin list  # WordPress CLI
docker-compose exec mariadb mysql -u root -p  # MySQL CLI

# View service status
docker-compose ps

# Restart services
docker-compose restart      # All services
docker-compose restart nginx # Specific service

# Rebuild and restart
docker-compose up -d --build
```

### Accessing Container Shells

```bash
# Access Nginx container
docker-compose -f srcs/docker-compose.yml exec nginx /bin/sh

# Access WordPress container (PHP-FPM)
docker-compose -f srcs/docker-compose.yml exec wordpress /bin/bash

# Access MariaDB container
docker-compose -f srcs/docker-compose.yml exec mariadb /bin/bash

# Inside MariaDB, connect to database
mysql -u root -p$MARIADB_ROOT_PASSWORD
mysql -u wordpress -p$WORDPRESS_DB_PASSWORD wordpress
```

---

## Data Storage and Persistence

### Volume Types Used

#### Named Volumes

```yaml
volumes:
  wordpress:
    driver: local
  mariadb:
    driver: local
```

**Characteristics**:
- Managed by Docker daemon
- Data persists even if containers are deleted
- Located at `/var/lib/docker/volumes/[volume_name]/_data`
- Survive `docker-compose down`

**Operations**:
```bash
# List volumes
docker volume ls

# Find volume location
docker volume inspect inception_wordpress -f '{{.Mountpoint}}'

# Backup volume
sudo tar -czf wordpress-backup.tar.gz -C /var/lib/docker/volumes/inception_wordpress/_data .

# Restore volume
sudo tar -xzf wordpress-backup.tar.gz -C /var/lib/docker/volumes/inception_wordpress/_data

# Remove volume
docker volume rm inception_wordpress
```

### Data Storage Locations

#### Host Machine
```
/home/megardes/data/wordpress/    # WordPress files (if using bind mounts)
/home/megardes/data/mariadb/      # MySQL data files (if using bind mounts)
```

#### Docker Volumes (Preferred)
```
/var/lib/docker/volumes/inception_wordpress/_data/
/var/lib/docker/volumes/inception_mariadb/_data/
```

### Persistence Behavior

| Operation | Data Result |
|-----------|-------------|
| `docker-compose down` | Data persists (volumes retained) |
| `docker-compose down -v` | Data deleted (volumes removed) |
| Container crash/restart | Data persists |
| Container deletion | Data persists (volume remains) |
| Host reboot | Data persists |
| `make clean` | Data persists |
| `make good_clean` | Data deleted |
| `make fclean` | Data deleted |
| `make purge` | All Docker resources deleted |

### Database Persistence

MariaDB data persists in the `mariadb` volume:

```bash
# Check database size
docker exec inception-mariadb-1 du -sh /var/lib/mysql

# Backup database
docker exec inception-mariadb-1 mysqldump -u root -p$MARIADB_ROOT_PASSWORD \
  --all-databases > mariadb-backup.sql

# Restore database
docker exec -i inception-mariadb-1 mysql -u root -p$MARIADB_ROOT_PASSWORD \
  < mariadb-backup.sql
```

### WordPress File Persistence

WordPress files persist in the `wordpress` volume:

```bash
# List WordPress files in volume
docker run --rm -v inception_wordpress:/data alpine ls -la /data

# Find WordPress configuration
docker run --rm -v inception_wordpress:/data alpine cat /data/wp-config.php

# Backup WordPress files
docker run --rm -v inception_wordpress:/data -v $(pwd):/backup \
  alpine tar czf /backup/wordpress-files.tar.gz -C /data .
```

---

## Development Workflow

### Local Development Loop

#### 1. Create/Modify Code

- Edit Dockerfiles in `requirements/[service]/`
- Update configuration files in `requirements/[service]/conf/`
- Modify setup scripts in `requirements/[service]/tools/`

#### 2. Rebuild Services

```bash
# Rebuild specific service
docker-compose -f srcs/docker-compose.yml build nginx --no-cache

# Rebuild and restart
docker-compose -f srcs/docker-compose.yml up -d --build nginx
```

#### 3. Test Changes

```bash
# View logs for new service
docker-compose -f srcs/docker-compose.yml logs -f nginx

# Access container to test
docker-compose -f srcs/docker-compose.yml exec nginx /bin/sh

# Test connectivity
curl -k https://megardes.42.fr
```

#### 4. Iterate

Repeat steps 1-3 as needed.

### Version Control

Create `.gitignore`:

```bash
cat > .gitignore << 'EOF'
# Environment and secrets
.env
.env.local
*.key
*.pem

# Docker artifacts (optional)
docker-compose.override.yml

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Data (if using bind mounts)
data/wordpress/*
data/mariadb/*
EOF
```

### Branching Strategy

```bash
# Create feature branch
git checkout -b feature/nginx-optimization

# Make changes and commit
git add .
git commit -m "Optimize Nginx configuration"

# Push to remote
git push origin feature/nginx-optimization

# Create pull request and merge after review
```

---

## Debugging and Troubleshooting

### Common Issues

#### 1. Port Already in Use

```
Error: bind: address already in use
```

**Solution**:
```bash
# Find process using port
lsof -i :80
lsof -i :443
lsof -i :3306

# Kill process
sudo kill -9 [PID]

# Or use different ports in docker-compose.yml:
# ports:
#   - "8080:80"
#   - "8443:443"
```

#### 2. Container Won't Start

```bash
# Check logs
docker-compose -f srcs/docker-compose.yml logs -f [service]

# Check container status
docker-compose -f srcs/docker-compose.yml ps

# Rebuild from scratch
docker-compose -f srcs/docker-compose.yml down -v
docker-compose -f srcs/docker-compose.yml build --no-cache
docker-compose -f srcs/docker-compose.yml up -d
```

#### 3. Database Connection Failed

```bash
# Verify MariaDB is running
docker-compose -f srcs/docker-compose.yml ps mariadb

# Check MariaDB logs
docker-compose -f srcs/docker-compose.yml logs mariadb

# Test database connectivity
docker-compose -f srcs/docker-compose.yml exec wordpress \
  mysql -h mariadb -u wordpress -p$WORDPRESS_DB_PASSWORD -e "SELECT 1;"

# Check environment variables
docker-compose -f srcs/docker-compose.yml exec wordpress env | grep WORD
```

#### 4. WordPress Installation Issues

```bash
# Check WordPress directory
docker-compose -f srcs/docker-compose.yml exec wordpress ls -la /var/www/wordpress

# Check file permissions
docker-compose -f srcs/docker-compose.yml exec wordpress stat /var/www/wordpress

# Check setup script execution
docker-compose -f srcs/docker-compose.yml logs wordpress | grep setup
```

#### 5. SSL Certificate Issues

```bash
# Generate self-signed certificate
docker-compose -f srcs/docker-compose.yml exec nginx /bin/sh -c \
  "openssl req -x509 -days 365 -nodes -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/private.key \
  -out /etc/nginx/ssl/certificate.crt"

# Verify certificate
docker-compose -f srcs/docker-compose.yml exec nginx \
  openssl x509 -in /etc/nginx/ssl/certificate.crt -text -noout
```

### Debugging Tools

#### Docker Logs

```bash
# All services
docker-compose -f srcs/docker-compose.yml logs

# Follow logs
docker-compose -f srcs/docker-compose.yml logs -f

# Last N lines
docker-compose -f srcs/docker-compose.yml logs --tail=100

# Specific service
docker-compose -f srcs/docker-compose.yml logs nginx
```

#### Container Inspection

```bash
# Detailed container info
docker inspect [container_name]

# Show network connections
docker run --rm --net inception_network nicolaka/netshoot \
  ip a

# Test DNS resolution
docker run --rm --net inception_network nicolaka/netshoot nslookup mariadb
```

#### Performance Analysis

```bash
# Monitor resources
docker stats

# Check memory usage
docker inspect [container_name] -f '{{.State.Pid}}' | xargs ps aux

# Check disk usage
docker exec [container_name] df -h
```

### Development Tips

1. **Use `.dockerignore`** to exclude unnecessary files from build context
2. **Leverage build cache** by ordering Dockerfile commands (frequently changed last)
3. **Use health checks** in docker-compose to auto-restart failed services
4. **Keep images small** by using multi-stage builds
5. **Document your changes** in commit messages and update documentation
6. **Test locally** before pushing to repository
7. **Use environment variables** for configuration (not hardcoded values)
8. **Regularly update base images** for security patches

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://specs.opencontainers.org/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [MariaDB Docker Image](https://hub.docker.com/_/mariadb)
- [WordPress Docker Image](https://hub.docker.com/_/wordpress)
- [Nginx Docker Image](https://hub.docker.com/_/nginx)
