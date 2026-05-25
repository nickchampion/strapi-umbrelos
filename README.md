# Strapi — UmbrelOS App

An [UmbrelOS](https://umbrel.com) app that self-hosts [Strapi v5](https://strapi.io) Headless CMS with a PostgreSQL database.

## Repository layout

```
strapi-umbrelos/
├── app/                        # Strapi v5 project (Docker build context)
│   ├── config/                 # database, server, middleware, plugin config
│   ├── src/index.ts            # Strapi register/bootstrap hooks
│   ├── public/                 # Static assets (uploads mounted at runtime)
│   ├── package.json
│   └── tsconfig.json
├── Dockerfile                  # Multi-stage production build
├── docker-compose.yml          # UmbrelOS orchestration
├── umbrel-app.yml              # UmbrelOS app manifest
├── exports.sh                  # Per-app environment variable exports
├── icon.svg                    # 256×256 app icon (replace before submission)
└── .github/workflows/
    └── docker-publish.yml      # Build + push to ghcr.io on version tag
```

## Publishing a new Docker image

Images are built and pushed automatically via GitHub Actions when you push a version tag:

```bash
git tag v5.13.0
git push origin v5.13.0
```

The workflow builds for `linux/amd64` and `linux/arm64` and pushes to:

```
ghcr.io/nickchampion/strapi-umbrelos:<version>
```

After the build completes, copy the SHA256 digest printed in the Actions log into `docker-compose.yml`:

```yaml
image: ghcr.io/nickchampion/strapi-umbrelos:5.13.0@sha256:<digest>
```

## Updating for a new Strapi version

1. Update `@strapi/strapi` and related packages in [app/package.json](app/package.json)
2. Push a new version tag → GitHub Actions rebuilds and pushes the image
3. Copy the new SHA256 digest into [docker-compose.yml](docker-compose.yml)
4. Update `version` and `releaseNotes` in [umbrel-app.yml](umbrel-app.yml)
5. Submit a PR to [getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps)

## Testing locally with umbrel-dev

Requires [umbrel-dev](https://github.com/getumbrel/umbrel-dev) and [OrbStack](https://orbstack.dev) (macOS) or Docker with exposed container IPs.

```bash
# Install the app from this local source
./umbrel-dev install strapi --source /path/to/strapi-umbrelos
```

Access at `http://umbrel-dev.local:1337`.

**Verification checklist:**
- [ ] Strapi admin UI loads at `/admin`
- [ ] First-run account creation completes
- [ ] Data persists across `docker compose restart`
- [ ] Uploads directory survives restart
- [ ] Uninstall + reinstall produces a clean state

## Persistent data

| Host path (relative to `APP_DATA_DIR`) | Purpose |
|---|---|
| `data/db/` | PostgreSQL database files |
| `data/uploads/` | Strapi media uploads |

Both directories are created by UmbrelOS before the containers start.

## Secrets

All secrets are derived deterministically from the per-installation `APP_SEED` in [exports.sh](exports.sh). They are stable across restarts and unique per Umbrel device — no manual secret management required.

## App Store submission

1. Fork [getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps)
2. Copy `docker-compose.yml`, `umbrel-app.yml`, `exports.sh`, `icon.svg`, and gallery images into a `strapi/` directory
3. Fill in the `submission` field in `umbrel-app.yml` with your PR URL
4. Open a pull request — maintainers will normalise image digests and review config

Gallery images must be `1440×900px PNG`. The icon must be a `256×256 SVG` with no rounded corners (UmbrelOS applies its own corner radius).

## Database backups

UmbrelOS does not provide a built-in backup API. To back up your Strapi data, run a `pg_dump` against the PostgreSQL container:

```bash
docker exec strapi_db_1 pg_dump -U strapi strapi > strapi-backup.sql
```

Or copy the raw data directory from `${APP_DATA_DIR}/data/db/` when the database is stopped.
