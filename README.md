# Plantilla de infraestructura Laravel

Este repo se usa como base para copiar/pegar infraestructura en nuevos proyectos Laravel.

## Requisitos

- Docker + Docker Compose plugin.

## Archivos principales

- `docker-compose.yml`: entorno local (nginx + php + mysql + scheduler + node + mailpit + phpmyadmin).
- `docker-compose.dokploy.yml`: entorno de deploy para Dokploy (server + php + scheduler + mysql + migrate one-shot).
- `docker-compose.dokploy.example.yml`: referencia comentada del compose de Dokploy.
- `.env.dokploy.example`: variables sugeridas para cargar en Dokploy.
- `CHECKLIST.md`: pasos para copiar esta infraestructura a un proyecto nuevo.

## Estructura esperada al reutilizar

La plantilla asume que tu proyecto final tendrá algo como:

- `src/` (app Laravel)
- `dockerfiles/`
- `nginx/default.conf`
- `mysql/.env`

## Servicios locales

- App: `http://localhost:${WEB_PORT:-8080}`
- phpMyAdmin: `http://localhost:${PMA_PORT:-8090}`
- Mailpit UI: `http://localhost:8025`
- Mailpit SMTP: `mailpit:1025`
- Vite dev server: `http://localhost:5173`
- Scheduler Laravel: servicio `scheduler` (`php artisan schedule:work`)

## Comandos locales

- Levantar: `docker compose up -d --build`
- Detener: `docker compose down`
- Ver estado: `docker compose ps`
- Logs: `docker compose logs -f server php node scheduler mysql`

Laravel dentro de `php`:

- Artisan: `docker compose exec php php artisan <comando>`
- Composer: `docker compose exec -T php composer <comando>`

## Variables de entorno

Infra (raiz del repo):

- `PROJECT_NAME`, `WEB_PORT`, `PMA_PORT`, `UID`, `GID`
- tags de imagen (`MYSQL_IMAGE_TAG`, `PHPMYADMIN_IMAGE_TAG`, `PHP_BASE_IMAGE`, etc.)

Laravel (`src/.env`) para pruebas con Mailpit:

```env
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=no-reply@tu-dominio.com
MAIL_FROM_NAME="${APP_NAME}"
```

## Deploy con Dokploy

Dokploy debe usar `docker-compose.dokploy.yml`.

Flujo recomendado:

1. Cargar variables desde `.env.dokploy.example` en Dokploy.
2. Verificar `APP_KEY`, credenciales de DB y SMTP reales.
3. Desplegar usando `docker-compose.dokploy.yml`.

Si necesitas correrlo manualmente:

- Levantar: `docker compose -f docker-compose.dokploy.yml up -d --build`
- Bajar: `docker compose -f docker-compose.dokploy.yml down`

## Notas

- No subir secretos: `mysql/.env`, `src/.env`.
- `src/vendor` y `public/build` se generan durante el build de deploy.
