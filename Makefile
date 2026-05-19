NAME = inception

all: 
	sudo mkdir -p /home/megardes/data/wordpress
	sudo mkdir -p /home/megardes/data/mariadb
	cd srcs && docker compose up -d --build

clean:
	cd srcs && docker compose down

fclean: clean
	docker system prune -af

re: fclean all

.PHONY: all clean fclean re
