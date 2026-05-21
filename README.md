*This project has been created as part of the 42 curriculum by megardes.*

## Description

**Inception** is a 42 curriculum project designed to teach containerization and infrastructure orchestration using Docker and Docker Compose. The project involves setting up a complete web stack consisting of:

- **Nginx**: A high-performance web server and reverse proxy
- **WordPress**: A popular content management system (CMS)
- **MariaDB**: A robust relational database system

The goal is to demonstrate a deep understanding of Docker concepts, container networking, data persistence, and the coordination of multiple services. This project reinforces best practices in containerized application deployment and helps understand the transition from traditional Virtual Machine-based infrastructure to modern container-based solutions.

## Instructions

### Prerequisites
- Docker Engine installed and running
- Docker Compose installed
- A Linux/Unix-based system (macOS or Linux recommended)

### Compilation & Installation

1. **Clone or navigate to the project directory**:
   ```bash
   cd /home/megardes/inception
   ```

2. **Build and start the containers**:
   ```bash
   make
   ```
   This command builds all Docker images and starts the services defined in `srcs/docker-compose.yml`.

3. **Environment Configuration**:
   - Configure environment variables as needed in your `.env` file (if used)
   - Ensure all required secrets or credentials are properly set

### Execution

Once the containers are running:

- **Access WordPress**: Open your browser and navigate to `localhost` or `https://localhost`
- **Access Services**:
  - Nginx listens only on port 443 (HTTPS)
  - WordPress runs as a PHP-FPM service
  - MariaDB runs on port 3306 (internal to the Docker network)

### Management Commands

- **Show available rules**: `make help`
- **Stop containers**: `make clean`
- **Full cleanup (including data)**: `make fclean`
- **Remove all Docker resources**: `make purge`

## Resources

### Documentation & References
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose File Format](https://docs.docker.com/compose/compose-file/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [WordPress on Docker](https://hub.docker.com/_/wordpress)
- [MariaDB Documentation](https://mariadb.com/docs/)

### AI Usage

AI was used in the following areas:
- Research and drafting the Markdown files and `Makefile` rules.


## Project Architecture & Docker Design Choices

This section details the architectural decisions and Docker implementation aspects of the Inception project.

### Project Structure

The project is organized as follows:
- **`srcs/docker-compose.yml`**: Orchestrates all three services in a single Docker network
- **`requirements/nginx/`**: Nginx configuration and Dockerfile
- **`requirements/wordpress/`**: WordPress setup scripts and Dockerfile
- **`requirements/mariadb/`**: MariaDB configuration, setup scripts, and Dockerfile

### Main Design Choices

1. **Microservice Architecture**: Each service (Nginx, WordPress, MariaDB) runs in its own container for isolation and independent scaling
2. **Docker Networking**: Custom bridge network ensures secure inter-container communication
3. **Volume Management**: Persistent storage for database files and WordPress data
4. **Environment-Based Configuration**: Secrets and sensitive data managed via environment variables
5. **Non-Root User Execution**: Containers run with limited privileges for security

### Comparison: Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|------------------|
| **Isolation** | Full OS isolation | Process-level isolation via kernel |
| **Startup Time** | Minutes (boot entire OS) | Seconds (start lightweight container) |
| **Resource Usage** | Heavy (full OS kernel + apps) | Lightweight (shared kernel + app layer) |
| **Performance** | Near-native but overhead | Native performance with minimal overhead |
| **Portability** | Limited (OS-specific) | Highly portable (works on any Docker host) |
| **Management** | Complex (manage OS + app) | Simplified (containerize once, run anywhere) |
| **Storage** | GB to tens of GB per VM | MB to hundreds of MB per image |

**Decision for Inception**: Docker was chosen for its efficiency, portability, and alignment with modern DevOps practices. Containers enable rapid deployment and scaling while consuming far fewer resources than VMs.

### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|-----------------|
| **Storage** | In plaintext or encoded in compose files | Encrypted, managed by Docker or orchestrator |
| **Access Control** | Available to all processes in container | Limited to specific services (advanced setups) |
| **Security Risk** | High (exposed in compose files, process lists) | Lower (encrypted at rest) |
| **Simplicity** | Very simple (key=value pairs) | Requires Docker Swarm or external secret manager |
| **Use Case** | Non-sensitive config, development | Production passwords, API keys, certificates |

**Implementation Choice**: For this project, environment variables are used for flexibility and ease of setup. In production, Docker Secrets or external secret managers (Vault, AWS Secrets Manager) should be used for sensitive data like database passwords.

### Docker Network vs Host Network

| Aspect | Docker Bridge Network | Host Network |
|--------|---------------------|--------------|
| **Isolation** | Containers isolated from host, connected via virtual network | Container stack directly uses host network interface |
| **Performance** | Slight overhead from virtual network | Minimal overhead |
| **Port Binding** | Must explicitly map container ports to host | Direct access to all host ports |
| **Security** | Better isolation between containers and host | Less isolation, security depends on app |
| **Use Case** | Development, multi-service deployments | High-performance single-service cases |
| **Communication** | Via container DNS names and fixed IPs | Uses localhost or direct host IPs |

**Design Choice**: This project uses a custom Docker bridge network to allow Nginx, WordPress, and MariaDB to communicate securely using container names as DNS while remaining isolated from the host network.

### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|------------|
| **Management** | Managed by Docker daemon | Managed by user |
| **Location** | Docker-managed directory | Any path on host filesystem |
| **Performance** | Optimized, better on Docker Desktop | Native performance on Linux, slower on Docker Desktop |
| **Portability** | Easier to migrate (encapsulated) | Path-dependent (may break on different systems) |
| **Permissions** | Docker manages permissions | User manages permissions |
| **Backup** | Can be backed up via Docker commands | Manual or script-based backup |
| **Use Case** | Production databases, managed data | Development, source code, config files |

**Implementation Strategy**:
- **Volumes**: Used for MariaDB data persistence (`/var/lib/mysql`) to ensure data survives container restarts
- **Volumes**: Used for WordPress data (`/var/www/wordpress`) for production-like behavior
- **Bind Mounts**: Used for configuration files and setup scripts to enable easy modifications during development

This approach balances development flexibility with production-readiness and data safety.

## How Docker and Docker Compose Work

### Docker Fundamentals

**Docker** is a containerization platform that packages applications and their dependencies into isolated, lightweight, and portable containers. Here's how it works:

1. **Docker Engine**: The core runtime that executes containers. It manages images, containers, networks, and storage.
2. **Docker Images**: Read-only blueprints containing all necessary files, libraries, and configurations needed to run an application. Images are built from Dockerfiles.
3. **Docker Containers**: Runtime instances of Docker images. They are lightweight, ephemeral processes that execute in isolation from the host system.

**Workflow**:
```
Dockerfile → Docker Build → Docker Image → Docker Run → Docker Container
```

### Docker Compose

**Docker Compose** is an orchestration tool that simplifies managing multi-container applications. Instead of running individual `docker run` commands for each container, Compose uses a YAML configuration file (`docker-compose.yml`) to define and coordinate multiple services.

**Key Features**:
- **Service Definition**: Define all containers (services) in a single YAML file
- **Networking**: Automatically creates a bridge network connecting all services
- **Volume Management**: Easily define persistent storage for containers
- **Environment Variables**: Centralized configuration management
- **Startup Orchestration**: Services can depend on each other, controlling startup order

**Workflow**:
```
docker-compose.yml → docker-compose up → All Services Running in Network
```

For this project, Docker Compose orchestrates:
- Nginx (web server)
- WordPress (PHP-FPM application)
- MariaDB (database)

All three services communicate via the Docker bridge network using service names as DNS hostnames.

## Docker Image Behavior: With vs Without Docker Compose

### Without Docker Compose (Manual Docker)

When using Docker without Compose, you must manually manage each container:

```bash
# Build image
docker build -t myapp:latest .

# Create network
docker network create mynetwork

# Run containers individually
docker run --name database --network mynetwork -e MYSQL_ROOT_PASSWORD=secret mysql:5.7
docker run --name app --network mynetwork -p 8080:80 myapp:latest
```

**Characteristics**:
- **Standalone**: Each container is independent and self-contained
- **Static Configuration**: Network, volumes, and environment are hardcoded in commands
- **Manual Orchestration**: You must manage startup order, networking, and cleanup manually
- **Scaling**: Adding new containers requires writing new commands
- **Reproducibility**: Hard to version control and rebuild the same setup consistently

### With Docker Compose

Using the same images with Docker Compose:

```yaml
version: '3.8'
services:
  database:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: secret
    networks:
      - mynetwork

  app:
    build: .
    image: myapp:latest
    ports:
      - "8080:80"
    networks:
      - mynetwork
    depends_on:
      - database

networks:
  mynetwork:
    driver: bridge
```

**Characteristics**:
- **Declarative**: The entire stack is defined in one file
- **Coordinated**: Services automatically connect to the same network
- **Orchestrated**: Compose handles startup order (via `depends_on`), networking, and resource management
- **Reproducible**: Others can recreate the exact same environment with `docker-compose up`
- **Scalable**: Easily replicate services or modify configuration centrally
- **Simple Commands**: Single commands like `docker-compose up` and `docker-compose down` manage everything

**Key Difference**: The Docker images themselves are identical in both cases. The difference lies in **how they are managed and orchestrated**. Docker Compose simplifies multi-container deployments by automating orchestration, networking, and configuration management.

## Benefits of Docker Compared to Virtual Machines

Docker provides significant advantages over traditional Virtual Machines:

### 1. **Resource Efficiency**
   - **VMs**: Require a full OS kernel (GB of storage, hundreds of MB of RAM per VM)
   - **Docker**: Share host kernel, using only application-specific layers (MB of storage, minimal RAM overhead)
   - **Impact**: Run many more containers than VMs on the same hardware

### 2. **Startup Speed**
   - **VMs**: Minutes to boot a full operating system
   - **Docker**: Seconds to start a container
   - **Impact**: Rapid scaling and faster development iterations

### 3. **Portability**
   - **VMs**: Limited by the OS inside (Linux VM won't work on Windows Host without compatibility layers)
   - **Docker**: "Build once, run anywhere" - same container works on Linux, macOS, Windows
   - **Impact**: Eliminate "works on my machine" problems

### 4. **Performance**
   - **VMs**: Hypervisor overhead (typically 10-30% performance loss)
   - **Docker**: Native-level performance (minimal overhead from process isolation)
   - **Impact**: Applications run at near-native speeds

### 5. **Simplified Management**
   - **VMs**: Manage OS patches, security updates, dependencies for each VM
   - **Docker**: Container image is immutable; updates happen at image level
   - **Impact**: Consistent environments and easier version control

### 6. **Scalability**
   - **VMs**: IP-based scaling is complex and resource-intensive
   - **Docker**: Easy horizontal scaling via orchestrators (Docker Compose, Kubernetes)
   - **Impact**: Applications scale efficiently with demand

### Use Case for This Project:
Docker enables Inception to run a full three-tier web stack (Nginx, WordPress, MariaDB) efficiently on a single development machine without the overhead of three separate virtual machines.

## Directory Structure and Its Pertinence

The Inception project follows a specific directory structure that reflects Docker and DevOps best practices:

```
inception/
├── Makefile                    # Automation for building and running the project
├── README.md                   # Project documentation
├── DEV_DOC.md
├── USER_DOC.md
└── srcs/
    ├── .env                    # Environment values used by mariadb and wordpress 
    ├── docker-compose.yml      # Orchestration file defining all services
    └── requirements/           # Directory housing Dockerfile for each service
        ├── nginx/
        │   ├── Dockerfile      # Instructions to build Nginx image
        │   ├── conf/
        │   │   └── nginx.conf  # Nginx configuration file
        ├── wordpress/
        │   ├── Dockerfile      # Instructions to build WordPress image
        │   └── tools/
        │       └── setup.sh    # Initialization script
        └── mariadb/
            ├── Dockerfile      # Instructions to build MariaDB image
            ├── conf/
            │   └── 50-server.cnf  # MariaDB configuration
            └── tools/
                └── setup.sh    # Initialization script
```

### Why This Structure?

1. **Separation of Concerns**
   - Each service (nginx, wordpress, mariadb) has its own directory
   - Configuration and scripts are logically grouped
   - Changes to one service don't affect others

2. **Docker Best Practices**
   - `Dockerfile` at the root of each service directory enables `docker build` to locate it easily
   - Configuration files in `conf/` are mounted as volumes into containers
   - Setup scripts in `tools/` handle initialization (e.g., database setup, WordPress installation)

3. **Centralized Orchestration**
   - `docker-compose.yml` in `srcs/` centralizes all service definitions
   - Single entry point for understanding the full stack

4. **Separation from Source Code**
   - Infrastructure code (`srcs/`) is separate from application code
   - Easy to version control and maintain

5. **Scalability and Maintenance**
   - Adding a new service is as simple as creating a new subdirectory under `requirements/`
   - Each Dockerfile follows the same pattern for consistency
   - Easy for team members to understand the project structure

6. **Makefile Integration**
   - The Makefile references `srcs/` directory, making the project easy to build and manage
   - Simple commands like `make` and `make clean` abstract away complexity

### How Each Component Fits:

| Component | Purpose | Location |
|-----------|---------|----------|
| **Dockerfile** | Defines image build process | `requirements/[service]/` |
| **Conf files** | Runtime configuration | `requirements/[service]/conf/` |
| **Setup scripts** | Container initialization | `requirements/[service]/tools/` |
| **docker-compose.yml** | Service orchestration | `srcs/` |
| **Makefile** | Project automation | Root directory |

This structure ensures clarity, maintainability, and adherence to Docker best practices, making the project scalable and easier for others to understand and extend.

## Additional Notes

- Ensure Docker and Docker Compose are properly installed before attempting to run this project
- On Linux systems, adding your user to the `docker` group allows running Docker commands without `sudo`
- This project demonstrates best practices but is primarily educational; production deployments require additional hardening
