FROM alpine:3.22

RUN apk add --no-cache \
    mariadb mariadb-client

COPY ./conf/50-server.cnf /etc/my.cnf.d/mariadb-server.cnf

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld

COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["sh", "/usr/local/bin/setup.sh"]