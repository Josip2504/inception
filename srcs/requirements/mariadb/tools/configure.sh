#!/bin/bash
set -e

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

echo "Starting temporary MariaDB server..."
su -s /bin/bash mysql -c "mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock --log-error=/tmp/mysql_debug.log" &
for i in {30..0}; do
    if mysqladmin ping --socket=/var/run/mysqld/mysqld.sock > /dev/null 2>&1; then
        break
    fi
    sleep 1
done
if [ "$i" = 0 ]; then
    echo "Failed to start MariaDB for setup."
    exit 1
fi

echo "MariaDB log:"
cat /tmp/mysql_debug.log || echo "No debug log found."

: "${MYSQL_ROOT_PASSWORD:=${MYSQL_ROOT_PASSWORD_FILE:+$(cat $MYSQL_ROOT_PASSWORD_FILE)}}"
: "${MYSQL_PASSWORD:=${MYSQL_PASSWORD_FILE:+$(cat $MYSQL_PASSWORD_FILE)}}"
: "${MYSQL_USER:=${MYSQL_USER_FILE:+$(cat $MYSQL_USER_FILE)}}"
: "${MYSQL_DATABASE:=wordpress}"

mysql --socket=/var/run/mysqld/mysqld.sock <<-EOSQL
    SET @@SESSION.SQL_LOG_BIN=0;
    DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'root') OR host NOT IN ('localhost');
    CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock

exec "$@"

