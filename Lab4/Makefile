ifneq (,$(wildcard ./.env))
    include .env
    export
endif

execute:
	docker exec "${CONTAINER_NAME}" mongosh --username "${DB_USR}" --password "${DB_PWD}" --file /scripts/init.js

run:
	docker compose up --detach

stop:
	docker stop "${CONTAINER_NAME}"

connect:
	docker exec -it "${CONTAINER_NAME}" /bin/bash

connect-to-bd:
	docker exec -it "${CONTAINER_NAME}" mongosh --username "${DB_USR}" --password "${DB_PWD}"

