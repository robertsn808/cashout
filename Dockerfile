FROM php:8.2-cli

# System deps
RUN apt-get update && apt-get install -y \
    libpq-dev libzip-dev unzip git curl \
 && docker-php-ext-install pdo_mysql pdo_pgsql zip

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . /app

# Install PHP deps & prep Laravel
RUN cd /app/casino && composer install --no-dev --optimize-autoloader --no-interaction \
 && php artisan key:generate --force \
 && mkdir -p public \
 && echo '<?php require_once __DIR__."/../bootstrap/app.php"; $app = require_once __DIR__."/../bootstrap/app.php"; $app->run();' > public/index.php \
 && php artisan storage:link || true

# Node for PTWebSocket daemons
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && cd /app/casino/PTWebSocket && npm ci || true

ENV PORT=8080
EXPOSE 8080
CMD sh -lc '\
  cd /app/casino; \
  (php artisan migrate --force || true); \
  ([ -d /app/casino/PTWebSocket ] && cd /app/casino/PTWebSocket && npx pm2 start Arcade.js && npx pm2 start Server.js && npx pm2 start Slots.js || true); \
  php -S 0.0.0.0:$PORT -t /app/casino/public \
'