upstream puma {
	      server localhost:3000;
}

server {
	listen 80;
	#listen [::]:8080 default_server ipv6only=on;

	server_name dev.mihudie.com;
	root /home/mhd/rails/public;
	index index.html index.htm;

	#location ^~ /images/ /javascripts/ /stylesheets/ {
	#      gzip_static on;
	#      expires max;
	#      add_header Cache-Control public;
	#}

	try_files $uri/index.html $uri @puma;

	location @puma {
	      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_set_header Host $http_host;
	      proxy_redirect off;
	      proxy_pass http://puma;
	}

	#location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		#try_files $uri $uri/ =404;
		# Uncomment to enable naxsi on this location
		# include /etc/nginx/naxsi.rules
	#}

}
