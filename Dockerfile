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
 && php artisan storage:link || true

# Node for PTWebSocket daemons
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && cd /app/casino/PTWebSocket && npm ci || true

ENV PORT=8080
EXPOSE 8080
CMD sh -lc '\
  cd /app/casino; \
  echo "Setting up environment..."; \
  cp .env.production .env; \
  sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-127.0.0.1}/" .env; \
  sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT:-5469}/" .env; \
  sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-casino_db}/" .env; \
  sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-casino_user}/" .env; \
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env; \
  sed -i "s/APP_ENV=.*/APP_ENV=${APP_ENV:-production}/" .env; \
  sed -i "s/APP_DEBUG=.*/APP_DEBUG=${APP_DEBUG:-false}/" .env; \
  sed -i "s|APP_URL=.*|APP_URL=${APP_URL:-https://cashout-0om5.onrender.com}|" .env; \
  php artisan config:clear; \
  php artisan cache:clear; \
  (php artisan migrate:status >/dev/null 2>&1 && echo "Database already migrated" || php artisan migrate --force || true); \
  ([ -d /app/casino/PTWebSocket ] && cd /app/casino/PTWebSocket && npx pm2 start Arcade.js && npx pm2 start Server.js && npx pm2 start Slots.js || true); \
  # Serve Laravel correctly from the public directory using the router script \
  php -S 0.0.0.0:$PORT -t /app/casino/public /app/casino/server.php \
'
