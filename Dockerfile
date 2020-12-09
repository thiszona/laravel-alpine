FROM alpine:3.12

LABEL Maintainer="Zona Budi Prastyo <zona.budi11@gmail.com>"

ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# make sure you can use HTTPS
RUN apk --update add ca-certificates busybox-suid

RUN echo "https://dl.bintray.com/php-alpine/v3.12/php-7.4" >> /etc/apk/repositories
# Install packages
RUN apk --no-cache add librdkafka-dev \
    git \
    wget \
    make \
    autoconf \
    php \
    php-fpm \
    php-opcache \
    php-openssl \
    php-curl \
    php-bz2 \
    php-exif \
    php-pgsql \
    php-sqlite3 \
    php-json \
    php-xml\
    php-mbstring \
    php-bcmath \
    php-redis \
    php-zip \
    php-gd \
    php-xsl \
    php-dev \
    php-phar \
    php-pdo \
    php-pdo_pgsql \
    php-xmlreader \
    php-ctype \
    php-iconv \
    php-dom \
    php-zlib \
    gcc \
    musl-dev \
    pcre2-dev \
    nginx supervisor curl

RUN pecl install rdkafka

# https://github.com/codecasts/php-alpine/issues/21
RUN ln -s /usr/bin/php7 /usr/bin/php

#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer;

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Remove default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Give Access to www-data
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1
RUN chown -R www-data:www-data /var/www/html

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]