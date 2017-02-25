FROM jwilder/dockerize

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

COPY json /json

ENTRYPOINT dockerize -timeout 300s -wait http://nexus:8081 -wait-http-header "Authorization:Basic YWRtaW46YWRtaW4xMjM=" \
    sh -c '\
    for json_file in `ls /json`; do \
      curl -v -X POST -u admin:admin123 \
        --header "Content-Type: application/json" \
        http://nexus:8081/service/extdirect \
        -d @"/json/${json_file}"; \
    done'
