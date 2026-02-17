# syntax=docker/dockerfile:1

ARG PHP_BASE_IMAGE=php:8.4-fpm-alpine
ARG COMPOSER_IMAGE_TAG=2.7.7

# -----------------------------
# Stage: Composer bin
# -----------------------------
FROM composer:${COMPOSER_IMAGE_TAG} AS composer_bin

# -----------------------------
# Stage: Base PHP runtime
# -----------------------------
FROM ${PHP_BASE_IMAGE} AS base

ARG INSTALL_XDEBUG=false
ARG XDEBUG_VERSION=3.5.0
ARG REDIS_PECL_VERSION=6.1.0

WORKDIR /var/www/html

RUN apk add --no-cache \
    mysql-client msmtp perl wget procps shadow \
    libzip libpng libjpeg-turbo libwebp freetype icu

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-dev zlib-dev libzip-dev \
    libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev linux-headers && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install \
        gd mysqli pdo_mysql intl bcmath opcache exif zip && \
    if [ "$INSTALL_XDEBUG" = "true" ]; then \
        pecl install xdebug-${XDEBUG_VERSION} && \
        docker-php-ext-enable xdebug && \
        printf "zend_extension=xdebug.so\nxdebug.mode=debug,develop\nxdebug.start_with_request=yes\nxdebug.discover_client_host=true\nxdebug.client_host=host.docker.internal\nxdebug.log_level=0\n" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    fi && \
    pecl install redis-${REDIS_PECL_VERSION} && \
    docker-php-ext-enable redis && \
    apk del .build-deps && \
    rm -rf /tmp/pear /usr/src/php*

COPY --from=composer_bin /usr/bin/composer /usr/local/bin/composer
COPY dockerfiles/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# -----------------------------
# Create laravel user/group + fix php-fpm user
# -----------------------------
ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} laravel && \
    adduser -G laravel -g laravel -s /bin/sh -D -u ${UID} laravel && \
    chown -R laravel:laravel /var/www/html

RUN sed -i \
  -e 's/^user = .*/user = laravel/' \
  -e 's/^group = .*/group = laravel/' \
  -e 's/^;\\?listen\\.owner = .*/listen.owner = laravel/' \
  -e 's/^;\\?listen\\.group = .*/listen.group = laravel/' \
  /usr/local/etc/php-fpm.d/www.conf

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD php-fpm -t || exit 1

# -----------------------------
# Stage: Vendor (composer install)
# -----------------------------
FROM base AS vendor

ENV COMPOSER_HOME=/tmp/composer

USER root
RUN mkdir -p /app /tmp/composer && \
    chown -R laravel:laravel /app /tmp/composer

WORKDIR /app

COPY --chown=laravel:laravel ./src/ ./

RUN mkdir -p /app/bootstrap/cache \
    /app/storage/framework/cache/data \
    /app/storage/framework/sessions \
    /app/storage/framework/views \
    /app/storage/logs && \
    chown -R laravel:laravel /app/bootstrap /app/storage && \
    chmod -R ug+rwX /app/bootstrap/cache /app/storage

USER laravel
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --optimize-autoloader

# -----------------------------
# Stage: Assets (Vite build)
# -----------------------------
FROM node:20-alpine AS assets
WORKDIR /app
COPY ./src/package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY ./src/ ./
RUN npm run build

# -----------------------------
# Stage: App (runtime final)
# -----------------------------
FROM base AS app

COPY --chown=laravel:laravel ./src /var/www/html
COPY --chown=laravel:laravel --from=vendor /app/vendor /var/www/html/vendor
COPY --chown=laravel:laravel --from=assets /app/public/build /var/www/html/public/build

USER root
RUN mkdir -p /var/www/html/bootstrap/cache \
    /var/www/html/storage/framework/cache/data \
    /var/www/html/storage/framework/sessions \
    /var/www/html/storage/framework/views \
    /var/www/html/storage/logs && \
    chown -R laravel:laravel /var/www/html/bootstrap /var/www/html/storage && \
    chmod -R ug+rwX /var/www/html/bootstrap/cache /var/www/html/storage

WORKDIR /var/www/html
USER laravel
