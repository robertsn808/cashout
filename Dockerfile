FROM php:8.2-cli

# System deps
RUN apt-get update && apt-get install -y \
    libpq-dev libzip-dev unzip git curl mariadb-server \
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
  echo "Starting MariaDB..."; \
  mkdir -p /run/mysqld; chown -R mysql:mysql /run/mysqld /var/lib/mysql; \
  [ -d /var/lib/mysql/mysql ] || mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1; \
  mysqld_safe --skip-networking=0 --bind-address=127.0.0.1 >/tmp/mysqld.log 2>&1 & \
  for i in 1 2 3 4 5 6 7 8 9 10; do mysqladmin ping >/dev/null 2>&1 && break; echo "Waiting for MariaDB ($i)..."; sleep 1; done; \
  cd /app/casino; \
  echo "Setting up environment..."; \
  cp .env.production .env; \
  sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=${DB_CONNECTION:-mysql}/" .env; \
  sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-127.0.0.1}/" .env; \
  sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env; \
  sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-casino_db}/" .env; \
  sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-casino_user}/" .env; \
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env; \
  sed -i "s/APP_ENV=.*/APP_ENV=${APP_ENV:-production}/" .env; \
  sed -i "s/APP_DEBUG=.*/APP_DEBUG=${APP_DEBUG:-false}/" .env; \
  sed -i "s|APP_URL=.*|APP_URL=${APP_URL:-https://cashout-0om5.onrender.com}|" .env; \
  echo "Provisioning database and user..."; \
  mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE:-casino_db} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; \
                   CREATE USER IF NOT EXISTS '${DB_USERNAME:-casino_user}'@'%' IDENTIFIED BY '${DB_PASSWORD}'; \
                   GRANT ALL PRIVILEGES ON ${DB_DATABASE:-casino_db}.* TO '${DB_USERNAME:-casino_user}'@'%'; FLUSH PRIVILEGES;" || true; \
  if [ ! -f /app/.db_imported ]; then \
    if [ -f /app/v105.sql ]; then \
      echo "Importing schema/data from v105.sql"; \
      mysql -uroot ${DB_DATABASE:-casino_db} < /app/v105.sql && touch /app/.db_imported; \
    fi; \
  fi; \
  php artisan config:clear; \
  php artisan cache:clear; \
  # optional: run framework migrations if any (non-fatal) \
  (php artisan migrate --force || true); \
  ([ -d /app/casino/PTWebSocket ] && cd /app/casino/PTWebSocket && npx pm2 start Arcade.js && npx pm2 start Server.js && npx pm2 start Slots.js || true); \
  # Serve Laravel correctly from the public directory using the router script \
  php -S 0.0.0.0:$PORT -t /app/casino/public /app/casino/server.php \
'
