# Repository Guidelines

## Project Structure & Module Organization
- `casino/`: Laravel backend (app, routes, resources, tests, vendor). Primary API and business logic.
- `frontend/`: Public themes (Default, Simple, Warmest, White) used by the site.
- `woocasino/`: Static assets (css, js, images) for the public site.
- `back/`: AdminLTE assets and build sources (Grunt/bower) for the admin UI skin.
- Root: `index.php`, `install.php`, configs (`*.json`), security docs (`docs/`, `SECURITY.md`).

## Build, Test, and Development Commands
- Install PHP deps: `cd casino && composer install`
- Env setup: `cp .env.example .env && php artisan key:generate`
- Frontend assets (Laravel Mix): `npm ci && npm run dev` (use `npm run prod` for minified builds)
- Run app locally: `php artisan serve` (default http://127.0.0.1:8000)
- Tests: `./vendor/bin/phpunit` (or `php artisan test`) from `casino/`
- Optional admin skin build: `cd back && npm install && grunt` (only if editing AdminLTE sources)

## Coding Style & Naming Conventions
- Formatting: PSR-12 / Laravel preset via StyleCI (`casino/.styleci.yml`).
- Indentation: 4 spaces (`casino/.editorconfig`); YAML uses 2 spaces.
- PHP: Classes StudlyCase, methods camelCase, constants UPPER_SNAKE_CASE.
- JS/CSS in Mix bundles follow project conventions; prefer existing patterns.

## Testing Guidelines
- Framework: PHPUnit (`casino/phpunit.xml`).
- Location: `casino/tests`; name files `*Test.php` and keep unit/integration clear.
- Requirements: Include tests for new features/bug fixes; run `./vendor/bin/phpunit` before PRs.

## Commit & Pull Request Guidelines
- Commits: Short, imperative messages (e.g., "Fix payout rounding"); group related changes.
- Version tags exist in history (e.g., `v10.4`, `10.5 Release`); keep changelog entries concise when applicable.
- PRs: Provide description, linked issues, reproduction steps; include screenshots/GIFs for UI or theme changes; note config/migration impacts.

## Security & Configuration Tips
- Never commit secrets; configure via `casino/.env` (DB, APP_KEY, mail). See `SECURITY.md` and `docs/` for details.
- Run DB migrations when schema changes: `php artisan migrate` (and seed if provided).
