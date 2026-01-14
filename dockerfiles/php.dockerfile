ARG PHP_BASE_IMAGE=php:8.3.3-fpm-alpine
FROM ${PHP_BASE_IMAGE} AS base

ARG INSTALL_XDEBUG=false
ARG XDEBUG_VERSION=3.3.2
ARG REDIS_PECL_VERSION=6.0.2
ARG COMPOSER_IMAGE_TAG=2.7.2

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
    if [ "$INSTALL_XDEBUG" = "true" ]; then \
        pecl install xdebug-${XDEBUG_VERSION} && \
        docker-php-ext-enable xdebug && \
        printf "zend_extension=xdebug.so\nxdebug.mode=debug,develop\nxdebug.start_with_request=yes\nxdebug.discover_client_host=true\nxdebug.client_host=host.docker.internal\nxdebug.log_level=0\n" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    fi && \
    pecl install redis-${REDIS_PECL_VERSION} && \
    docker-php-ext-enable redis && \
    apk del .build-deps && \
    rm -rf /tmp/pear /usr/src/php*

# Opcache y ajustes de PHP
COPY dockerfiles/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Usuario no root (Laravel-friendly)
ARG UID=1000
ARG GID=1000
RUN addgroup -g ${GID} laravel && \
    adduser -G laravel -g laravel -s /bin/sh -D -u ${UID} laravel && \
    chown -R laravel:laravel /var/www/html

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD php-fpm -t || exit 1

USER laravel

FROM composer:${COMPOSER_IMAGE_TAG} AS vendor
WORKDIR /app
COPY ./src/composer.json ./src/composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --optimize-autoloader

FROM base AS app
COPY --chown=laravel:laravel ./src /var/www/html
COPY --chown=laravel:laravel --from=vendor /app/vendor /var/www/html/vendor
WORKDIR /var/www/html
USER laravel
