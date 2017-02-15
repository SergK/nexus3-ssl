# nexus3-ssl
Docker compose, nexus3 with ssl support, docker-proxy and anonymous pulling

# Installation

Install docker-compose in virtualenv

# Steps to deploy

* Update **env.config** file to meet your requirements:

```bash
  # Data volume root dir
  export VOLUME_PATH=/srv/nexus-data
  # will be accessable with https://SERVER_NAME
  export SERVER_NAME=nexus.sandbox.example.com
  # will be used in docker-proxy upstream configuration
  export UPSTREAM_DOCKER_REPO=https://docker-prod-virtual.docker.example.com
```

* Put `ssl.key` and `ssl.crt` files in in `nginx/ssl/` directory

# Automatic deployment steps on **Nexus** side

Implemeted by running `curl` with related `json` files

* Create [Remote User Token](https://books.sonatype.com/nexus-book/reference3/security.html#remote-user-token)
* Create **docker-dev** repository with listening on **8082** port
* Create **docker-proxy** repository with pointing to Upstream docker repo **UPSTREAM_DOCKER_REPO** defined in `env.config`
* Create **docker-virtual** repository with listening on **8083** port and which includes both:
   - docker-dev
   - docker-proxy

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
* Your nexus server will be available by address defined in `SERVER_NAME`
* Your dev repository for pushing/pulling - `dev-SERVER_NAME`
* Your proxy repository for pulling from upstream + dev - `virtual-SERVER_NAME`
For example:

```bash
# 1. nexus web interface available https://nexus.sandbox.example.com
# with admin:admin123 (nexus default credentials)
SERVER_NAME=nexus.sandbox.example.com

# 2. pushing to dev
docker push dev-nexus.sandbox.example.com/my-container:v1.0.0

# 3. pulling from virtual, which is dev+UPSTREAM_DOCKER_REPO
docker pull virtual-nexus.sandbox.example.com/debian:jessie
```

# Notes and limitations

* push/pull to docker-dev repo DOESN'T require authorization since we are doing this transparantly on proxy
* pull from docker-virtual (which is docker-dev + docker-proxy) can be done anonymously as well
