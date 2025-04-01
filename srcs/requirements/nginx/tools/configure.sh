#!/bin/bash
set -e

DOMAIN_NAME=${DOMAIN_NAME:-localhost}

# Create SSL directory with proper permissions
mkdir -p /etc/nginx/ssl
chown www-data:www-data /etc/nginx/ssl
chmod 700 /etc/nginx/ssl

# Generate certificates if missing
if [ ! -f /etc/nginx/ssl/ssl_cert.pem ] || [ ! -f /etc/nginx/ssl/ssl_key.pem ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/ssl_key.pem \
        -out /etc/nginx/ssl/ssl_cert.pem \
        -subj "/CN=${DOMAIN_NAME}"
    chmod 600 /etc/nginx/ssl/*
fi

sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/conf.d/ssl.conf

# Fix permissions
chown -R www-data:www-data /var/www/wordpress

exec "$@"
