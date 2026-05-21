*This project has been created as part of the 42 curriculum by <login1>[, <login2>[, <login3>[...]]].*

## Description
**Inception** is a system administration project focused on containerization. The goal is to build a small, secure web stack using Docker and Docker Compose with three services: Nginx, WordPress, and MariaDB.

This project uses Docker to isolate services and Docker Compose to orchestrate them as a single stack. The sources are organized under [srcs/docker-compose.yml](srcs/docker-compose.yml) and [srcs/requirements](srcs/requirements), where each service has its own Dockerfile and setup configuration.

## Instructions
### Prerequisites
- Docker Engine
- Docker Compose

### Build and Run
1. Open a terminal in the project directory.
2. Run:
   ```bash
   make
   ```
3. Access the site at https://megardes.42.fr and the admin panel at https://megardes.42.fr/wp-admin.

### Cleanup
- Stop containers: `make clean`
- Full cleanup (including data): `make fclean`
- Remove all Docker resources: `make purge`

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [WordPress Image](https://hub.docker.com/_/wordpress)
- [MariaDB Documentation](https://mariadb.com/docs/)

**AI Usage**: AI was used to draft the documentation outline, refine Makefile cleanup rules, and summarize technical comparisons.

## Project Architecture and Design Choices

### Main Design Choices
- One container per service (Nginx, WordPress, MariaDB) for isolation and clarity.
- Private Docker bridge network for internal communication.
- Persistent storage with Docker volumes for WordPress and MariaDB data.
- Environment variables for configuration in the development scope.

### Comparisons

**Virtual Machines vs Docker**
- VMs run a full guest OS and are heavier and slower to start.
- Docker containers share the host kernel, making them lighter and faster.

**Secrets vs Environment Variables**
- Environment variables are simple to use but less secure.
- Docker Secrets are more secure but require Swarm; not used here.

**Docker Network vs Host Network**
- A Docker bridge network isolates services and exposes only what is needed.
- Host networking exposes services directly on the host and reduces isolation.

**Docker Volumes vs Bind Mounts**
- Volumes are managed by Docker and better for portable, persistent data.
- Bind mounts map host paths and are better for local development files.
