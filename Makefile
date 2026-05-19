NAME = inception

all: 
	sudo grep -q "megardes.42.fr" /etc/hosts || sudo sh -c 'echo "127.0.0.1 megardes.42.fr" >> /etc/hosts'
	sudo mkdir -p /home/megardes/data/wordpress
	sudo mkdir -p /home/megardes/data/mariadb
	cd srcs && docker compose up 

clean:
	cd srcs && docker compose down

fclean: clean
	docker system prune -af
	sudo rm -rf /home/megardes/data/wordpress/*
	sudo rm -rf /home/megardes/data/mariadb/*

re: fclean all

.PHONY: all clean fclean re
