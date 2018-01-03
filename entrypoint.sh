#!/bin/bash

function file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(<"${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

file_env 'HOST_NAME'


if [ ! -f "/etc/squid/ssl/squid.key" ]; then
  openssl genrsa -out /etc/squid/ssl/squid.key 2048
  openssl req -new -key /etc/squid/ssl/squid.key -out /etc/squid/ssl/squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=$HOST_NAME"
  openssl x509 -req -days 3650 -in /etc/squid/ssl/squid.csr -signkey /etc/squid/ssl/squid.key -out /etc/squid/ssl/squid.crt
  cat /etc/squid/ssl/squid.key /etc/squid/ssl/squid.crt > /etc/squid/ssl/squid.pem
  echo "create squid SSL files."
fi

if [ ! -d "/usr/local/squid/var/cache" ]; then
  mkdir -p /usr/local/squid/var/cache
  chmod -R 777 /usr/local/squid/var/cache
  echo "create squid cache directory."
 fi

if [ ! -d "/usr/local/squid/var/logs" ]; then
  mkdir -p /usr/local/squid/var/logs
  chmod -R 777 /usr/local/squid/var/logs
  echo "create squid logs directory."
 fi

if [ ! -d "/usr/local/squid/var/run" ]; then
  mkdir -p /usr/local/squid/var/run
  chmod -R 777 /usr/local/squid/var/run
  echo "create squid run directory."
 fi


if [ ! -f "/etc/squid/squid.conf" ]; then
  cat | tee /etc/squid/squid.conf <<EOF
visible_hostname $HOST_NAME

http_port 3128
#Handling HTTP requests
http_port 3129 intercept
acl allowed_http_sites dstdomain "/etc/squid/accesswebsites.lst"
http_access allow allowed_http_sites

#Handling HTTPS requests
https_port 3130 cert=/etc/squid/ssl/squid.pem ssl-bump intercept
acl SSL_port port 443
http_access allow SSL_port
acl allowed_https_sites ssl::server_name "/etc/squid/accesswebsites.lst"
sslproxy_cafile /etc/ssl/certs/ca-certificates.crt
sslproxy_foreign_intermediate_certs /etc/squid/extra-intermediate-CA.pem
sslproxy_options NO_SSLv2,NO_SSLv3,SINGLE_DH_USE
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
  touch /etc/squid/accesswebsites.lst
fi

echo "Starting squid3..."
exec /usr/local/squid/sbin/squid -f /etc/squid/squid.conf -NYCd  1
