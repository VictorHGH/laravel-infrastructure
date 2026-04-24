# Laravel Infrastructure Template

Plantilla reutilizable para montar infraestructura Docker en nuevos proyectos Laravel.

## Que incluye

- `docker-compose.yml`: entorno local (nginx, php, mysql, scheduler, node, mailpit, phpmyadmin).
- `docker-compose.dokploy.yml`: entorno de despliegue para Dokploy.
- `docker-compose.dokploy.example.yml`: ejemplo comentado para referencia.
- `.env.dokploy.example`: variables sugeridas para configurar Dokploy.
- `CHECKLIST.md`: guia paso a paso para adoptar esta plantilla en un proyecto nuevo.

## Estructura esperada al copiar la plantilla

- `src/` (aplicacion Laravel)
- `dockerfiles/`
- `nginx/default.conf`

## Inicio rapido local

1. Copia y ajusta `.env` (infra).
2. Crea `src/.env` desde `src/.env.example`.
3. Levanta servicios:

```bash
docker compose up -d --build
```

5. Verifica:

- App: `http://localhost:${WEB_PORT:-8080}`
- phpMyAdmin: `http://localhost:${PMA_PORT:-8090}`
- Mailpit: `http://localhost:8025`
- Vite: `http://localhost:5173`

## Comandos utiles

```bash
docker compose ps
docker compose logs -f server php node scheduler mysql
docker compose exec php php artisan migrate
docker compose exec -T php composer install
```

## Deploy con Dokploy

- Selecciona `docker-compose.dokploy.yml` como archivo de despliegue.
- Carga variables de `.env.dokploy.example` en Dokploy.
- Verifica `APP_KEY`, `APP_URL`, `MYSQL_*` y `MAIL_*` antes de publicar.

Ejecucion manual equivalente:

```bash
docker compose -f docker-compose.dokploy.yml up -d --build
```

## Correo en local

En `src/.env` usa Mailpit:

```env
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

## Buenas practicas

- No versionar secretos (`.env`, `src/.env`).
- Mantener `exclude-for-prod.txt` y `.dockerignore` alineados al proyecto.
- Revisar `CHECKLIST.md` antes de copiar esta base a un repo nuevo.
