build:
	docker compose up --build -d

up:
	docker compose up -d

down:
	docker compose down --remove-orphans

node:
	docker compose exec node sh

init:
	@git pull
	@git submodule update --init
	@make build

cleanup:
	@make down
	@rm -rf app
