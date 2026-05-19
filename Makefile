NAME = inception

all: 
	mkdir -p /home/megardes/data/wordpress
	mkdir -p /home/megardes/data/mariadb
	cd srcs && docker-compose up -d --build

clean:
	cd srcs && docker-compose down

fclean: clean
	docker system prune -af

re: fclean all

.PHONY: all clean fclean re
