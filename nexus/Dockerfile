FROM jwilder/dockerize

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

COPY enableRut.json /

ENTRYPOINT dockerize -timeout 100s -wait http://nexus:8081 -wait-http-header "Authorization:Basic YWRtaW46YWRtaW4xMjM=" \
  curl -v -X POST -u admin:admin123 --header "Content-Type: application/json" 'http://nexus:8081/service/extdirect' -d @enableRut.json
