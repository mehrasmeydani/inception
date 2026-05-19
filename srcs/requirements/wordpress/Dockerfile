FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-cli \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/php /var/www/html
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Download WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

ENTRYPOINT ["/setup.sh"]
CMD ["php-fpm8.2", "-F"]