NAME = inception

all: up

up:
	@mkdir -p /home/${USER}/data/wordpress
	@mkdir -p /home/${USER}/data/database
	@docker-compose -f ./srcs/docker-compose.yml up --build -d

down:
	@docker-compose -f ./srcs/docker-compose.yml down

clean: down
	@docker system prune -a --force

fclean: clean
	@rm -rf /home/${USER}/data/wordpress
	@rm -rf /home/${USER}/data/database
	@docker volume prune --force
	@docker network prune --force

re: fclean all

.PHONY: all up down clean fclean re
