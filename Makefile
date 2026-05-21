NAME = inception

all: 
	sudo grep -q "megardes.42.fr" /etc/hosts || sudo sh -c 'echo "127.0.0.1 megardes.42.fr" >> /etc/hosts'
# 	sudo mkdir -p /home/megardes/data/wordpress
# 	sudo mkdir -p /home/megardes/data/mariadb
	cd srcs && docker compose up --build

clean:
	cd srcs && docker compose down

good_clean: clean
	sudo rm -rf /home/megardes/data/wordpress/*
	sudo rm -rf /home/megardes/data/mariadb/*

fclean: clean
	@echo "Stopping and removing compose services, volumes and images..."
	cd srcs && docker compose down -v --rmi all --remove-orphans || true
	@echo "Pruning unused Docker objects (including volumes)..."
	docker system prune -af --volumes || true
	@echo "Removing project data directories..."
	sudo rm -rf /home/megardes/data/wordpress/*
	sudo rm -rf /home/megardes/data/mariadb/*

re: fclean all

purge:
	docker stop $$(docker ps -qa); docker rm $$(docker ps -qa); docker rmi -f $$(docker images -qa); docker volume rm $$(docker volume ls -q); docker network rm $$(docker network ls -q) 2>/dev/null

# List rules for containers, images, volumes, networks, and processes
list-containers:
	@echo "=== Running Containers ===" && \
	docker ps && \
	echo "\n=== All Containers (including stopped) ===" && \
	docker ps -a

list-images:
	@echo "=== Docker Images ===" && \
	docker images

list-volumes:
	@echo "=== Docker Volumes ===" && \
	docker volume ls && \
	echo "\n=== Volume Details ===" && \
	docker volume ls -q | xargs -I {} docker volume inspect {} --format "{{.Name}}: {{.Mountpoint}}"

list-networks:
	@echo "=== Docker Networks ===" && \
	docker network ls && \
	echo "\n=== Inception Network Details ===" && \
	docker network inspect inception_network -f "{{json .Containers}}" 2>/dev/null || echo "Network not found or not running"

list-processes:
	@echo "=== Processes in Running Containers ===" && \
	docker ps --format "table {{.Names}}" | tail -n +2 | while read container; do \
		echo "\n--- Processes in $$container ---"; \
		docker top $$container; \
	done

list-stats:
	@echo "=== Container Resource Usage ===" && \
	docker stats --no-stream

list-logs:
	@echo "=== Recent Logs from All Services ===" && \
	cd srcs && docker-compose logs --tail=50

list-all: list-containers list-images list-volumes list-networks
	@echo "\n=== Summary ===" && \
	echo "Containers: $$(docker ps -q | wc -l) running, $$(docker ps -qa | wc -l) total" && \
	echo "Images: $$(docker images -q | wc -l)" && \
	echo "Volumes: $$(docker volume ls -q | wc -l)" && \
	echo "Networks: $$(docker network ls -q | wc -l)"

ps:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

status:
	@echo "=== Inception Project Status ===" && \
	echo "Containers:" && \
	docker ps -a --filter "name=inception" --format "table {{.Names}}\t{{.Status}}" && \
	echo "\nVolumes:" && \
	docker volume ls --filter "name=inception" --format "table {{.Name}}\t{{.Mountpoint}}" && \
	echo "\nNetwork:" && \
	docker network ls --filter "name=inception" --format "table {{.Name}}\t{{.Driver}}"

volume-paths:
	@echo "=== Docker Volume Paths and Sizes ===" && \
	for v in $$(docker volume ls -q); do \
		mp=$$(docker volume inspect $$v --format '{{.Mountpoint}}' 2>/dev/null); \
		echo "\n$$v: $$mp"; \
		if [ -n "$$mp" ] && [ -d "$$mp" ]; then \
			sudo du -sh "$$mp" 2>/dev/null || echo "  (size: unavailable)"; \
		else \
			echo "  (mountpoint not available)"; \
		fi; \
	done

help:
	@echo "\n${NAME} - Makefile Help" && \
	echo "================================\n" && \
	echo "USAGE: make <rule>\n" && \
	echo "BUILD & LIFECYCLE RULES:" && \
	echo "  all              - Build and start all services (Nginx, WordPress, MariaDB)" && \
	echo "  clean            - Stop containers (preserve data)" && \
	echo "  good_clean       - Stop containers and remove WordPress/MariaDB data" && \
	echo "  fclean           - Full cleanup: remove containers, images, data, and prune system" && \
	echo "  re               - Rebuild everything from scratch (good_clean + all)" && \
	echo "  purge            - Remove ALL Docker resources (containers, images, volumes, networks)" && \
	echo "\nCONTAINER & PROCESS LISTING RULES:" && \
	echo "  list-containers  - Show running and stopped containers" && \
	echo "  list-images      - List all Docker images with sizes" && \
	echo "  list-volumes     - Display volumes and their mount points" && \
	echo "  list-networks    - Show all networks and inception network details" && \
	echo "  list-processes   - List processes running inside containers" && \
	echo "  list-stats       - Show real-time container resource usage (CPU, memory)" && \
	echo "  list-logs        - Display last 50 lines of logs from all services" && \
	echo "  list-all         - Show all info (containers, images, volumes, networks, summary)" && \
	echo "\nQUICK STATUS RULES:" && \
	echo "  ps               - Quick table: container names, status, and ports" && \
	echo "  status           - Project-specific status (inception containers/volumes/networks)" && \
	echo "\nHELP:" && \
	echo "  help	         - Show this help message\n" && \
	echo "EXAMPLES:" && \
	echo "  make              - Start the project" && \
	echo "  make clean        - Stop containers" && \
	echo "  make list-all     - View comprehensive system status" && \
	echo "  make ps           - Quick container status" && \
	echo "  make list-logs    - View service logs" && \
	echo "  make purge        - Complete Docker cleanup\n"

.PHONY: all clean fclean re purge list-containers list-images list-volumes list-networks list-processes list-stats list-logs list-all ps status help -h
