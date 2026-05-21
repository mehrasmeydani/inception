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
	docker system prune -af
	sudo rm -rf /home/megardes/data/wordpress/*
	sudo rm -rf /home/megardes/data/mariadb/*

re: good_clean all

.PHONY: all clean fclean re
