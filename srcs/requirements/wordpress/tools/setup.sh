#!/bin/bash
sleep 10 # Wait for mariadb to start

cd /var/www/html

if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb:3306 \
        --allow-root
    
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$MYSQL_USER \
        --admin_password=$MYSQL_PASSWORD \
        --admin_email="admin@$DOMAIN_NAME" \
        --skip-email \
        --allow-root

    wp user create editor editor@$DOMAIN_NAME --role=editor --user_pass=$MYSQL_PASSWORD --allow-root
fi

exec "$@"