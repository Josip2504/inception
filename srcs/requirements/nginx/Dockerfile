FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/nginx /var/cache/nginx \
    && chown -R www-data:www-data /var/log/nginx /var/cache/nginx \
    && chmod -R 755 /var/log/nginx /var/cache/nginx

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/ssl.conf /etc/nginx/conf.d/ssl.conf
COPY ./tools/configure.sh /usr/local/bin/

RUN mkdir -p /etc/nginx/ssl && \
    chmod +x /usr/local/bin/configure.sh

VOLUME /var/www/wordpress

EXPOSE 443

ENTRYPOINT ["configure.sh"]
CMD ["nginx", "-g", "daemon off;"]
