FROM jwilder/dockerize

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

COPY json /json

ENTRYPOINT dockerize -timeout 300s -wait http://nexus:8081 -wait-http-header "Authorization:Basic YWRtaW46YWRtaW4xMjM=" \
    sh -c '\
    for json_file in `ls /json/0*`; do \
      curl -v -X POST -u admin:admin123 \
        --header "Content-Type: application/json" \
        http://nexus:8081/service/extdirect \
        -d @"${json_file}"; \
    done; \
    curl -v -u admin:admin123 -X POST --header "Content-Type: application/json" \
      "http://nexus:8081/service/siesta/rest/v1/script/" -d @/json/removeRepo.json; \
    curl -v -u admin:admin123 -X POST --header "Content-Type: text/plain" \
      "http://nexus:8081/service/siesta/rest/v1/script/deleteRepo/run"; \
    curl -v -X DELETE -u admin:admin123 "http://nexus:8081/service/siesta/rest/v1/script/deleteRepo";'
