FROM composer:latest
RUN addgroup -g 1000 laravel && \
    adduser -G laravel -g laravel -s /bin/sh -D laravel && \
    chown -R laravel:laravel /var/www/html
USER laravel
WORKDIR /var/www/html
ENTRYPOINT ["composer", "ignore-platform-reqs"]
