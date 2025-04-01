#!/bin/bash
set -e

# Wait for MariaDB to be ready (only needed if your WordPress install depends on DB)
while ! mysqladmin ping -h"mariadb" --silent; do
    sleep 1
done

# Configure WordPress if not already configured
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    # Create wp-config.php using environment variables
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="$(cat ${WORDPRESS_DB_PASSWORD_FILE})" \
        --dbhost="mariadb" \
        --path="/var/www/wordpress" \
        --allow-root \
        --skip-check

    # Set additional WP config constants
    wp config set WP_HOME "https://${DOMAIN_NAME}" --path="/var/www/wordpress" --allow-root
    wp config set WP_SITEURL "https://${DOMAIN_NAME}" --path="/var/www/wordpress" --allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --path="/var/www/wordpress" --allow-root; then
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Project" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="$(cat ${WORDPRESS_ADMIN_PASSWORD_FILE})" \
        --admin_email="admin@${DOMAIN_NAME}" \
        --path="/var/www/wordpress" \
        --allow-root
fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/wordpress

# Execute the main command (PHP-FPM)
exec "$@"
