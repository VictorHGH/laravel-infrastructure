# Entorno Laravel con Docker (dev y prod)

## Descripción general
Base genérica para proyectos Laravel con contenedores.
- Compose base + overrides por perfil (`dev` y `prod`).
- PHP multi-stage: `base` (montajes/Xdebug) y `app` (código empaquetado, sin montajes).
- Nginx no-root escuchando 8080 interno; se publica 8081 en staging.
- MySQL con volumen nombrado y healthcheck; composer/artisan disponibles en dev.

## Requisitos
- Docker y Docker Compose v2.
- Puertos libres: 8080 (interno app), 8081 (publicado en prod/staging), 8090 (phpMyAdmin solo dev).

## Estructura
- `docker-compose.yml`: base común (nginx + php-fpm + MySQL, sin montajes).
- `docker-compose.dev.yml`: override dev (montajes, Xdebug, phpMyAdmin, composer/artisan).
- `docker-compose.prod.yml`: override prod/staging (mapea 8081, sin Xdebug ni montajes de código).
- `dockerfiles/`: Dockerfiles de nginx, php (multi-stage con Xdebug opcional) y composer.
- `src/`: código de la app (montado en dev, copiado en prod).

## Variables de entorno
- Crea `mysql/.env` (no se versiona) con algo similar:
  ```
  MYSQL_ROOT_PASSWORD=root.pa55
  MYSQL_DATABASE=laravel
  MYSQL_USER=laravel
  MYSQL_PASSWORD=laravel.pa55
  ```
- Prepara el `.env` de Laravel dentro de `src/` (APP_KEY, DB_*, etc.).
- Usa tus UID/GID para evitar problemas de permisos: `UID=$(id -u) GID=$(id -g)`.

## Levantar en desarrollo
```bash
UID=$(id -u) GID=$(id -g) \
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d --build
```
Incluye:
- Montaje de `./src` en nginx/php/composer/artisan.
- Xdebug activado (host autodetect, modo debug+develop) en PHP usando `target: base`.
- phpMyAdmin en `http://localhost:8090`.

Comandos útiles en dev:
- Dependencias: `docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev run --rm composer install`
- APP_KEY: `docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev run --rm artisan key:generate`
- Migraciones: `docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev run --rm artisan migrate`

## Levantar en producción (staging) sin dominio
Se usa un puerto alterno para no chocar con otros sitios del servidor. En el override prod se mapea `8081:8080`.
```bash
UID=$(id -u) GID=$(id -g) \
docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile prod up -d --build
```
Acceso: `http://IP-del-servidor:8081`
Incluye:
- Código empaquetado en la imagen (`target: app`, sin montajes de host).
- Nginx expuesto internamente en 8080; se publica 8081.
- Xdebug deshabilitado, `APP_ENV=production`, `APP_DEBUG=false`.

## Guía rápida para CentOS 7 (staging sin dominio)
1) Instala Docker + Docker Compose v2 (binario `docker-compose-plugin`).
2) Clona el repo y coloca el código de Laravel en `src/`.
3) Prepara `mysql/.env` y `.env` de Laravel.
4) Abre el puerto 8081 en firewalld:
   ```bash
   sudo firewall-cmd --permanent --add-port=8081/tcp
   sudo firewall-cmd --reload
   ```
5) Levanta el stack:
   ```bash
   UID=$(id -u) GID=$(id -g) \
   docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile prod up -d --build
   ```
6) Verifica contenedores: `docker compose ps`.

Cuando tengas dominio + TLS:
- Cambia el mapeo a `80:8080` (y si quieres TLS, agrega un proxy frontal tipo Traefik/Caddy/Nginx que gestione certificados y enrute por dominio). El contenedor puede seguir escuchando 8080 sin root.

## Parar y limpiar
- Detener: `docker compose down`
- Detener y borrar datos de MySQL: `docker compose down -v`

## Notas
- Para Linux, `docker compose` ya agrega `host.docker.internal` vía `extra_hosts` en dev.
- Si necesitas builds reproducibles en CI/CD, agrega un `.dockerignore` excluyendo `vendor/` y `node_modules/` o aprovecha el multi-stage de PHP para instalar dependencias en el build.
- phpMyAdmin es solo para dev; no habilites el perfil `dev` en entornos productivos.
