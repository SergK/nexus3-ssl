# nexus3-ssl
Docker compose, nexus3 with ssl support, docker-proxy and anonymous pulling

# Installation

Install docker-compose in virtualenv
You user should also have sudo permissions for chown command

# Steps to deploy

* Update **env.config** file to meet your requirements:

```bash
# Data volume root dir
export VOLUME_PATH=/srv/nexus-data

# Java options
export JAVA_MIN_MEM=4096m
export JAVA_MAX_MEM=4096m

# will be accessable with https://WEB_SERVER_NAME
export WEB_SERVER_NAME=sandbox.example.com
export WEB_SERVER_PORT=443

# docker dev repo with anonymous push/pull
export DOCKER_DEV_NAME=sandbox.example.com
export DOCKER_DEV_PORT=5000

# docker virtual repo with anonymous pull
export DOCKER_VIRTUAL_NAME=sandbox.example.com
export DOCKER_VIRTUAL_PORT=5002
```

* Put `ssl.key` and `ssl.crt` files in in `nginx/ssl/` directory

# Automatic deployment steps on **Nexus** side

Implemeted by running `curl` with related `json` files

* Create [Remote User Token](https://books.sonatype.com/nexus-book/reference3/security.html#remote-user-token)
* Create **docker-dev** repository with listening on **DOCKER_DEV_PORT** port
* Create **docker-virtual** repository with listening on **DOCKER_VIRTUAL_PORT** port and which includes:
   - docker-dev

# Running
Please check **./manage.sh** for help
```bash
Usage: ./manage.sh ACTION

 ACTION:
   init                 [Optional] generate config files,
                        check ssl keys, build required images
   status               get containers status
   debug                run docker-compose in foreground
   start                start all containers in background
   stop                 stop all containers
```

# Usage
* Your nexus web interface will be available - `WEB_SERVER_NAME`
* Your dev repository for pushing/pulling - `DOCKER_DEV_NAME`
* Your repository for anonymous pulling from dev - `DOCKER_VIRTUAL_NAME`
For example:

```bash
# 1. nexus web interface available https://sandbox.example.com
# with admin:admin123 (nexus default credentials)
WEB_SERVER_NAME=sandbox.example.com

# 2. pushing to dev
docker login -u publisher -p publisher dev-nexus.sandbox.example.com:5000
docker push sandbox.example.com:5000/my-container:v1.0.0

# 3. pulling from virtual, which is dev
docker pull sandbox.example.com:5002/my-container:v1.0.0
```

# Notes and limitations

* push/pull to docker-dev repo REQUIRES authorization with default publisher:publisher
* pull from docker-virtual (which is docker-dev) can be done anonymously
