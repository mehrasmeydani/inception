#!/bin/sh
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    /usr/bin/mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DATABASE_NAME}\`;

CREATE USER IF NOT EXISTS '${DATABASE_USER}'@'%' IDENTIFIED BY '${DATABASE_PASSWD}';

GRANT ALL PRIVILEGES ON \`${DATABASE_NAME}\`.* TO '${DATABASE_USER}'@'%';

ALTER USER 'root'@'localhost'
IDENTIFIED BY '${DATABASE_ROOT_PASSWD}';

FLUSH PRIVILEGES;
EOF
fi

exec /usr/bin/mysqld --user=mysql --console