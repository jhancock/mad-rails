server {
  listen 80;
  listen 443 ssl spdy;
  server_name www.mihudie.com;

  access_log /var/log/nginx/mihudie.access.log;
  error_log /var/log/nginx/mihudie.error.log;

  ## SSL setting reference:
  ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
  ## https://wiki.mozilla.org/Security/Server_Side_TLS#Nginx
  ## Does not include https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security

  ssl on;
  ## production Comodo cert via Namecheap
  ssl_certificate /home/mhd/rails/ssl/mihudie-bundle.crt;
  ssl_certificate_key /home/mhd/rails/ssl/mihudie.key;
  # next line possibly not needed as ssl_certificate contains intermediates
  #ssl_trusted_certificate /home/mhd/rails/ssl/mihudie-bundle.crt;
  ssl_dhparam /home/mhd/rails/ssl/mihudie.dhparam.pem;

  ssl_prefer_server_ciphers on;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 5m;

  add_header Strict-Transport-Security max-age=15768000;

  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.4.4 8.8.8.8 valid=300s;
  resolver_timeout 10s;

  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;

  return 301 $scheme://mihudie.com$request_uri;
}

server {
  listen 80;
  listen 443 ssl spdy;

  server_name mihudie.com;
  access_log /var/log/nginx/mihudie.access.log;
  error_log /var/log/nginx/mihudie.error.log;

  ## SSL setting reference:
  ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
  ## https://wiki.mozilla.org/Security/Server_Side_TLS#Nginx
  ## Does not include https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security

  ssl on;
  ## production Comodo cert via Namecheap
  ssl_certificate /home/mhd/rails/ssl/mihudie-bundle.crt;
  ssl_certificate_key /home/mhd/rails/ssl/mihudie.key;
  # next line possibly not needed as ssl_certificate contains intermediates
  #ssl_trusted_certificate /home/mhd/rails/ssl/mihudie-bundle.crt;
  ssl_dhparam /home/mhd/rails/ssl/mihudie.dhparam.pem;

  ssl_prefer_server_ciphers on;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 5m;

  add_header Strict-Transport-Security max-age=15768000;

  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.4.4 8.8.8.8 valid=300s;
  resolver_timeout 10s;

  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;

  location ~* \.(js|css)$ {
    gzip_static on;
    expires max;
  }

  location ~* \.(png|jpg|jpeg|gif|ico)$ {
    expires max;
  }

  passenger_enabled on;
  passenger_ruby /home/mhd/.rbenv/shims/ruby;
  passenger_app_env production;
  passenger_min_instances 6;
  root         /home/mhd/rails/public;

  # redirect server error pages to the static page /50x.html
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
    root   html;
  }
}
