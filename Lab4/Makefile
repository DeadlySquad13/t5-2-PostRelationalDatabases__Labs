ifneq (,$(wildcard ./.env))
    include .env
    export
endif

execute:
	docker exec "${CONTAINER_NAME}" cqlsh --file /scripts/init.js

run:
	docker compose up --detach

stop:
	docker stop "${CONTAINER_NAME}"

connect:
	docker exec -it "${CONTAINER_NAME}" /bin/bash

