#!/bin/bash
set -e

IN_OPERATION="${1}"
BASE_DIR=$(dirname $(readlink -f "${0}"))
DOCKER_COMPOSE_CONF="${BASE_DIR}/docker-compose.yaml"

source "${BASE_DIR}/env.config"


function init_env () {
  sudo mkdir -p "${VOLUME_PATH}"
  sudo chown 200:200 -R "${VOLUME_PATH}"
  local TEMPATE_VARS
  local ARGS=()
  # discover template variables
  eval "TEMPLATE_VARS=($(grep -o '{{[^}]\+}}' nginx/nginx.conf.tpl | LC_ALL=C sort -u))"
  # dynamically create sed arguments based on discovered template variables and match them to environment variables
  for x in "${TEMPLATE_VARS[@]//[{\}]/}"; do
    ARGS+=(-e "$(eval "echo \"s#{{$x}}#\${$x}#g\"")")
  done
  sed "${ARGS[@]}" -- "${BASE_DIR}/nginx/nginx.conf.tpl" > "${BASE_DIR}/nginx/nginx.conf"

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
        docker-compose -f "${DOCKER_COMPOSE_CONF}" up --force-recreate
    ;;

    start)
        init_env
        check_ssl_key
        docker-compose -f "${DOCKER_COMPOSE_CONF}" up -d --no-recreate
    ;;

    stop)
        docker-compose -f "${DOCKER_COMPOSE_CONF}" down
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
