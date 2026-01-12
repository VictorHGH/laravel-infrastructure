FROM php:8.3-fpm-alpine

WORKDIR /var/www/html

# Dependencias runtime
RUN apk add --no-cache \
    mysql-client msmtp perl wget procps shadow \
    libzip libpng libjpeg-turbo libwebp freetype icu

# Dependencias build + extensiones PHP
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-dev zlib-dev libzip-dev \
    libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install \
        gd \
        mysqli \
        pdo_mysql \
        intl \
        bcmath \
        opcache \
        exif \
        zip && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    apk del .build-deps && \
    rm -rf /tmp/pear /usr/src/php*

# Usuario no root (Laravel-friendly)
ARG UID=1000
ARG GID=1000
RUN addgroup -g ${GID} laravel && \
    adduser -G laravel -g laravel -s /bin/sh -D -u ${UID} laravel && \
    chown -R laravel:laravel /var/www/html

USER laravel

