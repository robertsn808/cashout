#!/usr/bin/env bash
set -euo pipefail

# Local bootstrap for the Laravel app in ./casino
# - Installs Composer deps
# - Copies .env and sets APP_KEY
# - Runs migrations and seeds
# - Builds front-end assets

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR/casino"

echo "[1/6] Ensuring .env exists and APP_KEY is set"
if [ ! -f .env ]; then
  cp .env.example .env
fi
if ! grep -q '^APP_KEY=base64' .env; then
  php artisan key:generate
fi

echo "[2/6] Installing Composer dependencies"
composer install --no-interaction --prefer-dist --no-progress

echo "[3/6] Running migrations and seeders"
php artisan migrate --seed --force || true

echo "[4/6] Setting storage permissions and symlink"
php artisan storage:link || true
chmod -R 775 storage bootstrap/cache || true

echo "[5/6] Installing Node dependencies and building assets"
if command -v npm >/dev/null 2>&1; then
  (npm ci || npm install)
  (npm run dev || npm run production)
else
  echo "npm not found; skipping asset build"
fi

echo "[6/6] Done. Start the app with: php artisan serve"

