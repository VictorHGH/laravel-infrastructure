# Docker Compose aliases for this Laravel base
# Uso: source este archivo desde el root del proyecto o con ruta absoluta:
#   source ./docker-aliases.zsh
# Detecta la ruta del proyecto basada en la ubicación del script.

# Ruta del script (zsh) y root del proyecto
SCRIPT_PATH="${(%):-%x}"
SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

export COMPOSE_FILE_DEV="$PROJECT_ROOT/docker-compose.yml:$PROJECT_ROOT/docker-compose.dev.yml"
export COMPOSE_PROFILES_DEV="dev"
alias dcdev='COMPOSE_FILE="$COMPOSE_FILE_DEV" COMPOSE_PROFILES="$COMPOSE_PROFILES_DEV" docker compose'

export COMPOSE_FILE_PROD="$PROJECT_ROOT/docker-compose.yml:$PROJECT_ROOT/docker-compose.prod.yml"
export COMPOSE_PROFILES_PROD="prod"
alias dcprod='COMPOSE_FILE="$COMPOSE_FILE_PROD" COMPOSE_PROFILES="$COMPOSE_PROFILES_PROD" docker compose'

# Ejemplos:
#  Subir dev:    dcdev up -d --build
#  Composer:     dcdev run --rm composer install
#  Artisan:      dcdev run --rm artisan migrate
#  Subir prod:   dcprod up -d --build
