FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/my.cnf /etc/mysql/my.cnf
COPY ./tools/configure.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/configure.sh

VOLUME /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["configure.sh"]
CMD ["mysqld"]
