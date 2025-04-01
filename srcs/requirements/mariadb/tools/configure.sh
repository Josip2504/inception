#!/bin/bash

set -e

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
fi

# Start temporary server to set up users
temp_server_start() {
    mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    local i
    for i in {30..0}; do
        if mysqladmin ping --socket=/var/run/mysqld/mysqld.sock; then
            break
        fi
        sleep 1
    done
    if [ "$i" = 0 ]; then
        echo "Unable to start server."
        exit 1
    fi
}

temp_server_start

# Read secrets
MYSQL_ROOT_PASSWORD=$(cat ${MYSQL_ROOT_PASSWORD_FILE})
MYSQL_PASSWORD=$(cat ${MYSQL_PASSWORD_FILE})
MYSQL_USER=$(cat ${MYSQL_USER_FILE})

# Set up users
mysql --socket=/var/run/mysqld/mysqld.sock <<-EOSQL
    SET @@SESSION.SQL_LOG_BIN=0;
    DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'root') OR host NOT IN ('localhost');
    CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

# Stop temporary server
killall mysqld
wait

exec "$@"
