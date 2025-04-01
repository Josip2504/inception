#!/bin/bash
set -e

# Generate SSL certificates if they don't exist
if [ ! -f /etc/nginx/ssl/ssl_cert.pem ] || [ ! -f /etc/nginx/ssl/ssl_key.pem ]; then
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/ssl_key.pem \
        -out /etc/nginx/ssl/ssl_cert.pem \
        -subj "/CN=${DOMAIN_NAME}"
fi

# Replace DOMAIN_NAME in nginx config
sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/conf.d/ssl.conf

exec "$@"
