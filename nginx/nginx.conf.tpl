user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    proxy_send_timeout 120;
    proxy_read_timeout 300;
    proxy_buffering    off;
    keepalive_timeout  5 5;
    tcp_nodelay        on;

    ## Set a variable to help us decide if we need to add the
    ## 'Docker-Distribution-Api-Version' header.
    ## The registry always sets this header.
    ## In the case of nginx performing auth, the header will be unset
    ## since nginx is auth-ing before proxying.
    map $upstream_http_docker_distribution_api_version $docker_distribution_api_version {
      '' 'registry/2.0';
    }


    server {
        listen         80;
        server_name    {{SERVER_NAME}};

        return         301 https://$server_name$request_uri;
    }


    server {
      listen       *:443 ssl;
      server_name {{SERVER_NAME}};

      ssl on;

      ssl_certificate           /etc/nginx/ssl/ssl.crt;
      ssl_certificate_key       /etc/nginx/ssl/ssl.key;

      ssl_verify_client         off;

      ssl_session_cache         shared:SSL:10m;
      ssl_session_timeout       10m;
      ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
      ssl_ciphers               ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
      ssl_prefer_server_ciphers on;
      ssl_stapling              on;
      ssl_stapling_verify       on;

      location / {
        proxy_pass http://nexus:8081;
        proxy_read_timeout    120;
        proxy_connect_timeout 90;
        proxy_redirect        off;
        client_max_body_size 8G;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
      }

    }

    server {
      listen       *:443 ssl;
      server_name dev-{{SERVER_NAME}};

      ssl on;

      ssl_certificate           /etc/nginx/ssl/ssl.crt;
      ssl_certificate_key       /etc/nginx/ssl/ssl.key;

      ssl_verify_client         off;

      ssl_session_cache         shared:SSL:10m;
      ssl_session_timeout       10m;
      ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
      ssl_ciphers               ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
      ssl_prefer_server_ciphers on;
      ssl_stapling              on;
      ssl_stapling_verify       on;

      # will allow "anonymous" pulling
      # sandbox user should be created in nexus
      if ($authorization = '') {
        set $authorization 'Basic c2FuZGJveDpzYW5kYm94'; # sandbox:sandbox
      }

      location / {
        add_header 'Docker-Distribution-Api-Version' $docker_distribution_api_version always;
        proxy_pass http://nexus:8082;
        proxy_read_timeout    120;
        proxy_connect_timeout 90;
        proxy_redirect        off;
        client_max_body_size 8G;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
      }

    }

    server {
      listen       *:443 ssl;
      server_name virtual-{{SERVER_NAME}};

      ssl on;

      ssl_certificate           /etc/nginx/ssl/ssl.crt;
      ssl_certificate_key       /etc/nginx/ssl/ssl.key;

      ssl_verify_client         off;

      ssl_session_cache         shared:SSL:10m;
      ssl_session_timeout       10m;
      ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
      ssl_ciphers               ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
      ssl_prefer_server_ciphers on;
      ssl_stapling              on;
      ssl_stapling_verify       on;

      # will allow "anonymous" pulling
      # sandbox user should be created in nexus
      if ($authorization = '') {
        set $authorization 'Basic c2FuZGJveDpzYW5kYm94'; # sandbox:sandbox
      }

      location / {
        add_header 'Docker-Distribution-Api-Version' $docker_distribution_api_version always;
        proxy_set_header Authorization $authorization;
        proxy_pass http://nexus:8083;
        proxy_read_timeout    120;
        proxy_connect_timeout 90;
        proxy_redirect        off;
        client_max_body_size 8G;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
      }

    }

}
