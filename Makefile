entrypoint := python3
network := drf-dev
project := docker-drf

build:
	docker build --tag docker-drf:dev .

rebuild:
	docker build --no-cache --tag docker-drf:dev .

make-test-network:
	@docker network inspect drf-dev >/dev/null || docker network create drf-dev

postgres-start: make-test-network
	docker run --rm \
		--network drf-dev \
		--name docker-django-postgres \
		--env POSTGRES_PASSWORD=secret \
		--env POSTGRES_DB=${project} \
		-d -p 127.0.0.1:5432:5432 \
		postgres

postgres-shell:
	docker run -it --rm --network drf-dev \
		--env PGPASSWORD=secret \
		postgres psql -h docker-django-postgres -U postgres -d docker-drf

postgres-stop:
	docker kill docker-django-postgres

run: build make-test-network
	docker run --rm -it --name docker-drf-service --publish 127.0.0.1:7500:80/tcp \
		--network drf-dev \
		--env-file=.env \
		-e PORT=80 \
		docker-drf:dev

run-dev: build
	docker run --rm -it --name docker-drf-service --publish 127.0.0.1:7500:80/tcp \
		--network drf-dev \
		--env-file=.env \
		-v $(CURDIR)/src:/code \
		-v docker-drf-root:/root \
		--entrypoint ${entrypoint} \
		docker-drf:dev -Wd /code/manage.py runserver 0.0.0.0:80

run-initial: build
	docker run --rm -it --name docker-drf-service --publish 127.0.0.1:7500:80/tcp \
		--network drf-dev \
		--env-file=.env \
		-v $(CURDIR)/src:/code \
		-v docker-drf-root:/root \
		--entrypoint run django-admin startproject mysite .

# Get shell in the container started by `make run`
shell:
	docker exec -it docker-drf-service bash

# Get shell on a fresh container that isn't running the server
# The code directory is bound into the container so that any changes are persisted on the host
# This means you can run eg. ./manage.py makemigrations and commit the source that makemigrations generates
shell-only:
	docker run -it --rm \
		--network drf-dev \
		--env-file=.env \
		-v $(CURDIR)/src:/code \
		-v docker-drf-root:/root \
		--entrypoint bash \
		docker-drf:dev