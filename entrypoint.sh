#!/bin/bash

if [ ! -f "/etc/squid/squid.key" ]; then
  openssl genrsa -out /etc/squid/squid.key 2048
  openssl req -new -key /etc/squid/squid.key -out /etc/squid/squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=squid"
  openssl x509 -req -days 3650 -in /etc/squid/squid.csr -signkey /etc/squid/squid.key -out /etc/squid/squid.crt
  cat /etc/squid/squid.key /etc/squid/squid.crt | sudo tee /etc/squid/squid.pem
  echo "create squid SSL files."
fi

if [ ! -f "/etc/squid/squid.conf" ]; then
  cat | tee /etc/squid/squid.conf <<EOF
visible_hostname squid

#Handling HTTP requests
http_port 3129 intercept
acl allowed_http_sites dstdomain .amazonaws.com
#acl allowed_http_sites dstdomain [you can add other domains to permit]
http_access allow allowed_http_sites

#Handling HTTPS requests
https_port 3130 cert=/etc/squid/ssl/squid.pem ssl-bump intercept
acl SSL_port port 443
http_access allow SSL_port
acl allowed_https_sites ssl::server_name .amazonaws.com
#acl allowed_https_sites ssl::server_name [you can add other domains to permit]
acl step1 at_step SslBump1
acl step2 at_step SslBump2
acl step3 at_step SslBump3
ssl_bump peek step1 all
ssl_bump peek step2 allowed_https_sites
ssl_bump splice step3 allowed_https_sites
ssl_bump terminate step2 all

http_access deny all
EOF
  echo "create default squid conf."
fi


echo "Starting squid proxy."
exec /usr/local/squid/sbin/squid -f /etc/squid/squid.conf

