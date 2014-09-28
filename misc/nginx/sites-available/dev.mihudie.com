server {
	listen 80;
        #listen [::]:80 default_server ipv6only=on;

	access_log /var/log/nginx/mihudie.access.log;
	error_log /var/log/nginx/mihudie.error.log;

        server_name dev.mihudie.com;
        passenger_enabled on;
        passenger_ruby /home/mhd/.rbenv/shims/ruby;
        passenger_app_env development;
        passenger_min_instances 1;
        root         /home/mhd/rails/public;

        # redirect server error pages to the static page /50x.html
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
}
