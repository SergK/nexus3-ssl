# nexus3-ssl
Docker compose, nexus3 with ssl support

# Steps to deploy

* Update env.config to your needs
* Put `ssl.key` and `ssl.crt` files in in nginx/ssl/ directory

# Steps to deploy on **Nexus** side:

* Create **docker-dev** repository with listening on 8082 port
* Create **docker-proxy** repository with pointing to Upstream docker repo
* Create **docker-virtual** repository with listening on 8083 port and
   which includes both:
   - docker-dev
   - docker-proxy
* [Done] Configure a Request Header Authentication in Nexus Repository Manager
  * Go to "administration/system/capabilities" in the UI
  * Click on "Create capability" to add a new capability
  * Select the "Rut Auth" capability
  * Fill in the header name "X-Proxy_REMOTE-USER"
  * Save


# Running
Please check **./manage.sh** for help
```bash
Usage: ./manage.sh ACTION

 ACTION:
   init                 generate config files and check ssl keys
   status               get containers status
   debug                run docker-compose in foreground
   start                start all containers in background
   stop                 stop all containers
```
