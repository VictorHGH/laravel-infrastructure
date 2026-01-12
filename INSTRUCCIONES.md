# Puesta en marcha del entorno

## Requisitos
- Docker y Docker Compose instalados.
- Acceso a los puertos 8080 (app) y 8090 (phpMyAdmin, solo dev).

## Variables de entorno
Crea `mysql/.env` (no se versiona) con tus valores:
```
MYSQL_ROOT_PASSWORD=root.pa55
MYSQL_DATABASE=laravel
MYSQL_USER=laravel
MYSQL_PASSWORD=laravel.pa55
```
Prepara también el `.env` de Laravel dentro de `src/` (APP_KEY, DB_*, etc.).

## Primer arranque (en casa o trabajo)
Ejecuta con tu UID/GID para evitar problemas de permisos:
```
UID=$(id -u) GID=$(id -g) docker-compose up --build
```
Esto levanta Nginx (8080), PHP-FPM, MySQL, phpMyAdmin (8090), y contenedores utilitarios `composer`/`artisan`.

## Ciclo diario (sin reconstruir)
```
UID=$(id -u) GID=$(id -g) docker-compose up
```

## Comandos útiles
- Instalar dependencias: `docker-compose run --rm composer install`
- Generar APP_KEY: `docker-compose run --rm artisan key:generate`
- Migraciones: `docker-compose run --rm artisan migrate`
- Cachear config (prod): `docker-compose run --rm artisan config:cache`

## Limpieza
- Parar: `docker-compose down`
- Reiniciar desde cero (borra DB): `docker-compose down -v`

## Notas
- El volumen de MySQL es nombrado (`mysql_data`), por lo que vive en Docker y funciona igual en casa y en trabajo.
- El código se monta como volumen `./src`, así que basta con clonar el repo y usar los comandos anteriores en cualquier máquina.
- phpMyAdmin es solo para desarrollo; omite el puerto 8090 en producción.
