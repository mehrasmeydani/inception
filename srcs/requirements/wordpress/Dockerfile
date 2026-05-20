FROM alpine:3.23

RUN apk add --no-cache \
    php84-fpm php84-mysqli php84-phar php84-iconv \
    php84-mbstring php84-curl php84-dom php84-xml \
    php84-openssl php84-json php84-tokenizer \
    mysql-client wget curl tar busybox-extras fcgi

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/wordpress

COPY ./tools/setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

RUN sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' \
    /etc/php84/php-fpm.d/www.conf

RUN echo "memory_limit=512M" > /etc/php84/conf.d/memory-limit.ini

EXPOSE 9000

ENTRYPOINT ["sh", "/usr/local/bin/wp_setup.sh"]