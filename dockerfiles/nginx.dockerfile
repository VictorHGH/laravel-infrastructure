ARG NGINX_BASE_IMAGE=nginx:1.26.2-alpine
FROM ${NGINX_BASE_IMAGE}
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --chown=nginx:nginx ./src/public /var/www/html/public
WORKDIR /var/www/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- http://localhost:8080 || exit 1
USER nginx
