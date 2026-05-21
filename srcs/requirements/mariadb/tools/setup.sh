#!/bin/sh
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Creating Database!"
    mariadb-install-db  

    /usr/bin/mysqld --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DATABASE_NAME}\`;

CREATE USER IF NOT EXISTS '${DATABASE_USER}'@'%' IDENTIFIED BY '${DATABASE_PASSWD}';

GRANT ALL PRIVILEGES ON \`${DATABASE_NAME}\`.* TO '${DATABASE_USER}'@'%';

ALTER USER 'root'@'localhost'
IDENTIFIED BY '${DATABASE_ROOT_PASSWD}';

FLUSH PRIVILEGES;
EOF
echo "DATABASE CREATED!"
fi

exec /usr/bin/mysqld --console