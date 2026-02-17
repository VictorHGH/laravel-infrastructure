# Checklist de adopcion para nuevo proyecto Laravel

Usa esta lista cuando copies esta infraestructura a un nuevo repositorio.

## 1) Copia de estructura base

- [ ] Copiar al nuevo repo: `docker-compose.yml`, `docker-compose.dokploy.yml`, `dockerfiles/`, `nginx/`, `mysql/`, `.dockerignore`, `exclude-for-prod.txt`.
- [ ] Verificar que la app Laravel exista en `src/`.
- [ ] Confirmar que existan `src/package.json` (si usas Vite) y `src/.env.example`.

## 2) Ajustes de variables locales

- [ ] Editar `.env` (infra) con `PROJECT_NAME`, `WEB_PORT`, `PMA_PORT`, `UID`, `GID`.
- [ ] Crear `mysql/.env` desde `mysql/.env.example` y poner credenciales locales.
- [ ] Crear `src/.env` desde `src/.env.example`.
- [ ] En `src/.env`, para pruebas de correo local, usar `MAIL_HOST=mailpit` y `MAIL_PORT=1025`.

## 3) Levantar entorno local

- [ ] Ejecutar `docker compose up -d --build`.
- [ ] Validar contenedores con `docker compose ps`.
- [ ] Validar app en `http://localhost:${WEB_PORT}`.
- [ ] Validar Mailpit en `http://localhost:8025`.

## 4) Preparar deploy Dokploy

- [ ] Cargar variables en Dokploy usando `.env.dokploy.example` como referencia.
- [ ] Reemplazar secretos reales: `APP_KEY`, credenciales DB y SMTP.
- [ ] Confirmar que `APP_ENV=production` y `APP_DEBUG=false`.
- [ ] Confirmar `APP_URL` con dominio final.

## 5) Validaciones previas a deploy

- [ ] Revisar que `docker-compose.dokploy.yml` sea el archivo seleccionado en Dokploy.
- [ ] Verificar que `migrate` ejecute y termine correctamente.
- [ ] Verificar que `php` y `scheduler` queden en estado healthy/running.
- [ ] Verificar endpoint de health (`/health`) desde Nginx.

## 6) Post-deploy minimo

- [ ] Probar login y rutas principales.
- [ ] Probar comando Artisan dentro de contenedor `php`.
- [ ] Probar envio de correo real (SMTP de produccion).
- [ ] Revisar logs: `server`, `php`, `scheduler`, `mysql`.

## 7) Higiene de repositorio

- [ ] No subir secretos (`mysql/.env`, `src/.env`).
- [ ] Mantener `exclude-for-prod.txt` actualizado segun el proyecto.
- [ ] Documentar en README cualquier variable extra especifica del proyecto.
