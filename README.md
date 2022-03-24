Instructions for Bootstrapping a Django App within a Docker environment
===========================================

*The initial project and was forked from https://github.com/joeymasip/docker-django*

The idea of the project is to enable you to bootstrap a django project wholly within Docker. Most instructions demonstrate you setting up your project in your local development environment and then containerising after the event. This requires you to have setup your local developer environment for python and virtual environments and I'd like to avoid that by having everything within a container from the start.

The bootstrapping app looks like this:

```md
Project
|
+--docker
|  |
|  +--django
|     |
|     +--Dockerfile
|     \--requirements.txt
|
+--src
|  |
|  +-temp.txt
+--.env
+--.gitignore
+--docker-compose.yml
+--Dockerfile
+--Makefile
+--README.md
```

The files at the root of the project need some explanation:

- Dockerfile - this is a duplicate but will be used for creating the image for the final django project (referenced from the Makefile commands)
- docker-compose.yaml - this is required to bootstrap the initial app but from then on I will be orchestrating from the Makefile
- Makefile - to be used once the django app has been setup

Having setup the django project using the following instructions. You could delete the docker-compose.yaml and the docker folder.

## How to start django project (if not created)

- Change PROJECT_NAME in the `.env` file
- Make sure you modify python version & the requirements.txt for the django dockerfile.

### Create the images

- Run `docker-compose up -d` to create the images and start the containers. Django's container will not start, don't worry.

### Create django project

- Run `docker-compose run django django-admin.py startproject project_name ./src` to create project_name (creating in src to clearly demark the django files)

## How to run

Dependencies:

  * Docker engine v1.13 or higher. Your OS provided package might be a little old, if you encounter problems, do upgrade. See [https://docs.docker.com/engine/installation](https://docs.docker.com/engine/installation)
  * Docker compose v1.12 or higher. See [docs.docker.com/compose/install](https://docs.docker.com/compose/install/)

To run using the Makefile commands

- first start up the database service running in detached mode with `make postgres-start`
- then get the django container running with `make run-dev`
- You can access your application via **`127.0.0.1:7500`**
- In a separate terminal open a shell with `make shell` and create a new app `./manage.py startapp app_name` and run any migrations with `./manage.py migrate`

## Hosts within your environment

You'll need to configure your application to use any services you enabled:

Service|Hostname |Port number
-------|---------|-----------
django |django   |7500
mysql  |mysql    |8306

# Development hints

Once you have it up and running, you can now edit your settings.

## Django settings.py:

  * Add your app_name in the installed apps

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    'app_name',
]
```


  * Configure your settings.py so your databases point to each database services by service name! 

Change:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}
```
To
```python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "docker-drf",
        "USER": os.getenv("DOCKER_DJANGO_DATABASE_USER"),
        "PASSWORD": os.getenv("DOCKER_DJANGO_DATABASE_PASSWORD", ""),
        "HOST": os.getenv("DOCKER_DJANGO_DATABASE_HOST", "localhost"),
        "PORT": os.getenv("DOCKER_DJANGO_DATABASE_PORT", "5432"),
    }
}

```

## Django migrations:

In a separate terminal window, open the shell in your django container `make shell`

Now run the migrations like so

`python manage.py makemigrations`

And 

`python manage.py migrate`


## Docker compose cheatsheet

**Note:** you need to cd first to where your docker-compose.yml file lives.

  * Start containers in the background: `docker-compose up -d`
  * Start containers on the foreground: `docker-compose up`. You will see a stream of logs for every container running.
  * Stop containers: `docker-compose stop`
  * Kill containers: `docker-compose kill`
  * View container logs: `docker-compose logs`
  * Execute command inside of container: `docker-compose exec SERVICE_NAME COMMAND` where `COMMAND` is whatever you want to run. Examples:
    * Shell into the django container, `docker-compose exec django bash`
    * Open a mysql shell, `docker-compose exec mysql mysql -uroot -pCHOSEN_ROOT_PASSWORD`

## Docker general cheatsheet

**Note:** these are global commands and you can run them from anywhere.

  * To clear containers: `docker rm -f $(docker ps -a -q)`
  * To clear images: `docker rmi -f $(docker images -a -q)`
  * To clear volumes: `docker volume rm $(docker volume ls -q)`
  * To clear networks: `docker network rm $(docker network ls | tail -n+2 | awk '{if($2 !~ /bridge|none|host/){ print $1 }}')`