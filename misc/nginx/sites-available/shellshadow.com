server {
	listen 80;
	#listen [::]:8080 default_server ipv6only=on;

	server_name shellshadow.com www.shellshadow.com;
	root /home/jhancock/ss-www-static;
	index index.html index.htm;

	# jhancock
	default_type "text/html";

	## Redirect from www to non-www
	if ($host = 'www.shellshadow.com') {
		rewrite  ^/(.*)$  $scheme://shellshadow.com/$1  permanent;
	}

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
		# Uncomment to enable naxsi on this location
		# include /etc/nginx/naxsi.rules
	}

	#error_page 404 /404.html;

	# redirect server error pages to the static page /50x.html
	#
	#error_page 500 502 503 504 /50x.html;
	#location = /50x.html {
	#	root /usr/share/nginx/html;
	#}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}





