ARG NGINX_BASE_IMAGE=nginx:1.26.2-alpine

# ---- stage: assets (vite build) ----
FROM node:20-alpine AS assets
WORKDIR /app

COPY ./src/package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

COPY ./src/ ./
RUN npm run build

# ---- stage: nginx runtime ----
FROM ${NGINX_BASE_IMAGE}

RUN addgroup -S nginx || true && adduser -S -G nginx nginx || true

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

COPY ./src/public /var/www/html/public
COPY --from=assets /app/public/build /var/www/html/public/build

RUN mkdir -p /tmp/nginx/client_temp /tmp/nginx/proxy_temp /tmp/nginx/fastcgi_temp /tmp/nginx/uwsgi_temp /tmp/nginx/scgi_temp && \
    chown -R nginx:nginx /var/www/html /tmp/nginx || true

WORKDIR /var/www/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- http://localhost:8080/ >/dev/null 2>&1 || exit 1
USER nginx
