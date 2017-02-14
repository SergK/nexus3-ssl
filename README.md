# nexus3-ssl
Docker compose, nexus3 with ssl support

Steps to deploy

#. Update env.config to your needs
#. Put `ssl.key` and `ssl.crt` files in in nginx/ssl/ directory

Steps to deploy on *Nexus* side:

#. Create **docker-dev** repository with listening on 8082 port
#. Create **docker-proxy** repository with pointing to Upstream docker repo
#. Create **docker-virtual** repository with listening on 8083 port and
   which includes both:
   * docker-dev
   * docker-proxy
#. Create `sandbox` user in Nexus with `sandbox` password

Use ./manage.sh

