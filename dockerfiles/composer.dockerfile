FROM composer:latest
ARG UID=1000
ARG GID=1000
RUN addgroup -g ${GID} laravel && \
    adduser -G laravel -g laravel -s /bin/sh -D -u ${UID} laravel && \
    chown -R laravel:laravel /var/www/html
USER laravel
WORKDIR /var/www/html
ENTRYPOINT ["composer"]
