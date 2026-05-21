#!/bin/sh

set -e

export PHP_MEMORY_LIMIT=512M

if [ ! -f "/var/www/wordpress/wp-config.php" ]; then

    wp core download --path=/var/www/wordpress --allow-root

    wp config create \
        --dbname=$DATABASE_NAME \
        --dbuser=$DATABASE_USER \
        --dbpass=$DATABASE_PASSWD \
        --dbhost=mariadb \
        --path=/var/www/wordpress \
        --allow-root

    wp core install \
    --url="https://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWD \
        --admin_email=$WP_ADMIN_EMAIL \
        --path=/var/www/wordpress \
        --allow-root

    wp user create \
        $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWD \
        --role=contributor \
        --path=/var/www/wordpress \
        --allow-root

    echo "Wordpress was created Successfuly!"
fi

echo "starting php-fpm"
exec php-fpm84 -F