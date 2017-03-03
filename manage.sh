#!/bin/bash
set -e

IN_OPERATION="${1}"
BASE_DIR=$(dirname $(readlink -f "${0}"))
DOCKER_COMPOSE_CONF="${BASE_DIR}/docker-compose.yaml"

source "${BASE_DIR}/env.config"


function init_env () {
  git -C "${BASE_DIR}" submodule update --init --recursive
  sudo mkdir -p "${VOLUME_PATH}"
  sudo chown 200:200 -R "${VOLUME_PATH}"

  sed -e "s#{{WEB_SERVER_NAME}}#${WEB_SERVER_NAME}#g" \
      -e "s#{{WEB_SERVER_PORT}}#${WEB_SERVER_PORT}#g" \
      -e "s#{{DOCKER_DEV_NAME}}#${DOCKER_DEV_NAME}#g" \
      -e "s#{{DOCKER_VIRTUAL_NAME}}#${DOCKER_VIRTUAL_NAME}#g" \
      -e "s#{{DOCKER_DEV_PORT}}#${DOCKER_DEV_PORT}#g" \
      -e "s#{{DOCKER_VIRTUAL_PORT}}#${DOCKER_VIRTUAL_PORT}#g" \
      "${BASE_DIR}/nginx/nginx.conf.tpl" > "${BASE_DIR}/nginx/nginx.conf"
  echo "Updating nginx.conf"
}


function check_ssl_key () {
  if [[ -f "${BASE_DIR}/nginx/ssl/ssl.key"  &&  -f "${BASE_DIR}/nginx/ssl/ssl.crt" ]]; then
    echo "SSL keys file found, continue..."
  else
    echo "No ssl files found. Exiting"
    exit 1
  fi
}


case "${IN_OPERATION}" in

    init)
      init_env
      check_ssl_key
      docker-compose -f "${DOCKER_COMPOSE_CONF}" build
    ;;

    status)
        docker-compose -f "${DOCKER_COMPOSE_CONF}" ps
    ;;

    debug)
        init_env
        check_ssl_key
        docker-compose -f "${DOCKER_COMPOSE_CONF}" up --force-recreate --build
    ;;

    start)
        init_env
        check_ssl_key
        docker-compose -f "${DOCKER_COMPOSE_CONF}" up -d --no-recreate
    ;;

    stop)
        docker-compose -f "${DOCKER_COMPOSE_CONF}" down
    ;;

    clean)
        $0 stop
        docker rmi nginx nexus/manage sonatype/nexus3 jwilder/dockerize
    ;;

    *)
        cat << EOF
Usage: $0 ACTION

 ACTION:
   init                 [Optional] generate config files,
                        check ssl keys, build required images
   status               get containers status
   debug                run docker-compose in foreground
   start                start all containers in background
   stop                 stop all containers
EOF
        exit 1
    ;;
esac
