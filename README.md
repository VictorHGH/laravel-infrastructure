# Requisitos

- Docker + Docker Compose plugin.

---
## Archivos de compose

- `docker-compose.yml`: entorno local (app + mysql + phpmyadmin + mailpit).
- `docker-compose.dokploy.yml`: compose para Dokploy (deploy).

No se usan aliases ni overrides `docker-compose.dev.yml`.

---
## Servicios locales

- App: `http://localhost:${WEB_PORT:-8080}`
- phpMyAdmin: `http://localhost:${PMA_PORT:-8090}`
- Mailpit UI: `http://localhost:8025`
- Mailpit SMTP: `mailpit:1025`

---
## Comandos locales

- Levantar: `docker compose up -d --build`
- Detener: `docker compose down`
- Ver estado: `docker compose ps`
- Logs: `docker compose logs -f server php mysql`

Laravel dentro de `php`:

- Artisan: `docker compose exec php php artisan <comando>`
- Composer: `docker compose exec -T php composer <comando>`

---
## Variables de entorno

Infra (raiz del repo):

- `PROJECT_NAME`, `WEB_PORT`, `PMA_PORT`
- tags de imagen (`MYSQL_IMAGE_TAG`, `PHPMYADMIN_IMAGE_TAG`, etc.)

Laravel (`src/.env`) para Mailpit:

```env
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=no-reply@alumnos.xoc.uam.mx
MAIL_FROM_NAME="COSIES"
```

---
## Deploy con Dokploy

Dokploy debe usar `docker-compose.dokploy.yml`.

Archivos de apoyo:

- `.env.dokploy.example`: ejemplo de variables para cargar en Dokploy.
- `docker-compose.dokploy.example.yml`: ejemplo comentado para ver diferencias vs local.

Si necesitas ejecutar ese compose manualmente:

- Levantar: `docker compose -f docker-compose.dokploy.yml up -d --build`
- Bajar: `docker compose -f docker-compose.dokploy.yml down`

---
## Notas

- No subir secretos: `mysql/.env`, `src/.env`.
- `src/vendor` se genera durante build en entorno de deploy.
