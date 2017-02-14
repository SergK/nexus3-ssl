# nexus3-ssl
Docker compose, nexus3 with ssl support, docker-proxy and anonymous pulling

# Steps to deploy

* Update env.config to your needs
* Put `ssl.key` and `ssl.crt` files in in nginx/ssl/ directory

# Automatic deployment steps on **Nexus** side:

* Create **docker-dev** repository with listening on 8082 port
* Create **docker-proxy** repository with pointing to Upstream docker repo
  UPSTREAM_DOCKER_REPO defined in env.config
* Create **docker-virtual** repository with listening on 8083 port and
   which includes both:
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
