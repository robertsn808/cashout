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
  if [ ! -f .env ]; then \
    if [ -f .env.production ]; then \
      cp .env.production .env; \
    else \
      echo "Generating .env from Render env vars"; \
      cat > .env <<EOF\nAPP_NAME="Captain Cashout"\nAPP_ENV=${APP_ENV:-production}\nAPP_DEBUG=${APP_DEBUG:-false}\nAPP_KEY=${APP_KEY:-base64:dummy}\nAPP_URL=${APP_URL:-https://cashout-0om5.onrender.com}\nDB_CONNECTION=${DB_CONNECTION:-pgsql}\nDB_HOST=${DB_HOST:-127.0.0.1}\nDB_PORT=${DB_PORT:-5432}\nDB_DATABASE=${DB_DATABASE:-upp_production}\nDB_USERNAME=${DB_USERNAME:-upp_user}\nDB_PASSWORD=${DB_PASSWORD:-}\nCACHE_DRIVER=${CACHE_DRIVER:-redis}\nSESSION_DRIVER=${SESSION_DRIVER:-redis}\nQUEUE_CONNECTION=${QUEUE_CONNECTION:-redis}\nREDIS_HOST=${REDIS_HOST:-127.0.0.1}\nREDIS_PASSWORD=${REDIS_PASSWORD:-null}\nREDIS_PORT=${REDIS_PORT:-6379}\nEOF\n; \
    fi; \
  fi; \
  sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=${DB_CONNECTION:-pgsql}/" .env || true; \
  sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-127.0.0.1}/" .env || true; \
  sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT:-5432}/" .env || true; \
  sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-upp_production}/" .env || true; \
  sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-upp_user}/" .env || true; \
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env || true; \
  sed -i "s/APP_ENV=.*/APP_ENV=${APP_ENV:-production}/" .env || true; \
  sed -i "s/APP_DEBUG=.*/APP_DEBUG=${APP_DEBUG:-false}/" .env || true; \
  sed -i "s|APP_URL=.*|APP_URL=${APP_URL:-https://cashout-0om5.onrender.com}|" .env || true; \
  php artisan config:clear; \
  php artisan cache:clear; \
  # Optional: run framework migrations if any (non-fatal) \
  (php artisan migrate --force || true); \
  ([ -d /app/casino/PTWebSocket ] && cd /app/casino/PTWebSocket && npx pm2 start Arcade.js && npx pm2 start Server.js && npx pm2 start Slots.js || true); \
  # Serve Laravel correctly from the public directory using the router script \
  php -S 0.0.0.0:$PORT -t /app/casino/public /app/casino/server.php \
'
