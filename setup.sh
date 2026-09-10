#!/bin/bash

set -e

FLAG_FILE=/var/www/storage/app/.docker_initialized
APP_PORT=${APP_PORT:-8000}

git config --global --add safe.directory /var/www

composer install --no-interaction
composer dump-autoload

php artisan migrate --force
php artisan storage:link || true

if [ ! -f "$FLAG_FILE" ]; then
  echo "Executando comandos iniciais Laravel..."

  php artisan key:generate
  php artisan db:seed --force || true

  mkdir -p "$(dirname "$FLAG_FILE")"
  touch "$FLAG_FILE" || {
    echo "Erro: não foi possível criar a flag de inicialização em $FLAG_FILE"
    exit 1
  }
  echo "Setup inicial completo!"
else
  echo "Setup inicial já foi executado anteriormente, pulando..."
fi

php artisan config:clear
php artisan queue:restart || true

php artisan serve --host=0.0.0.0 --port=${APP_PORT:-8000}

exec "$@"
