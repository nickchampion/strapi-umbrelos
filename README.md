# Strapi — UmbrelOS App

An [UmbrelOS](https://umbrel.com) app that self-hosts [Strapi v5](https://strapi.io) Headless CMS with a Postgres database.

## Repository layout

```
strapi-umbrelos/
├── strapi/                     # Strapi v5 project (Docker build context)
│   ├── config/                 # database, server, admin, middleware, plugin config
│   ├── src/index.ts            # Strapi register/bootstrap hooks
│   ├── public/                 # Static assets (uploads mounted at runtime)
│   ├── docker-entrypoint.sh    # Container entrypoint (compile TS, then start)
│   ├── package.json
│   └── tsconfig.json
├── umbrelos/                   # UmbrelOS app-store files (submitted as-is)
│   ├── docker-compose.yml      # UmbrelOS orchestration (image pinned by digest)
│   ├── umbrel-app.yml          # UmbrelOS app manifest
│   ├── exports.sh              # Per-app environment variable exports
│   ├── icon.svg                # 256×256 app icon
│   └── 1.png / 2.png / 3.png  # 1440×900 gallery screenshots
├── scripts/
│   ├── dev.sh                  # Build image + run locally (simulates UmbrelOS env)
│   ├── publish.sh              # Build, push, pin digest, tag, and push git tag
│   ├── sideload.sh             # rsync umbrelos/ to a real Umbrel device for testing
│   └── cheatsheet.sh           # Quick reference for common commands
├── Dockerfile                  # Multi-stage production build
├── docker-compose.dev.yml      # Local dev overrides (port exposure, no app_proxy)
├── package.json                # Root scripts (dev, release, sideload)
└── .github/workflows/
    └── docker-publish.yml      # CI: build + push to ghcr.io on version tag
```

## Publishing a new Docker image

Use the publish script — it incremetns the app's revision (./umbrelos/umbrel-app.yml) builds the multi-arch image, pins the digest in `umbrelos/docker-compose.yml`, commits, and pushes the git tag in one step:

```bash
pnpm publish
# or: ./scripts/publish.sh
```

The script builds for `linux/amd64` and `linux/arm64`, pushes to GHCR, then automatically updates `umbrelos/docker-compose.yml` with the pinned digest:

```yaml
image: ghcr.io/nickchampion/strapi-umbrelos:v5.13.0@sha256:<digest>
```

One-time setup (authenticate with GHCR before first release):

```bash
echo "YOUR_GITHUB_PAT" | docker login ghcr.io -u nickchampion --password-stdin
```

## Updating for a new Strapi version

1. Update `@strapi/strapi` and related packages in [strapi/package.json](strapi/package.json)
2. Run `pnpm publish` — builds, pushes, and pins the digest automatically
3. Update `version` and `releaseNotes` in [umbrelos/umbrel-app.yml](umbrelos/umbrel-app.yml)
4. Submit a PR to [getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps)

## Testing locally

Requires Docker. The dev script builds the image, wires up secrets the same way UmbrelOS does via `exports.sh`, and mounts data into `.dev-data/`.

```bash
pnpm dev           # build image + start (foreground, Ctrl-C to stop)
pnpm dev:fresh     # skip build, start with existing local image
pnpm dev:down      # stop containers (keeps data)
```

Or run the script directly for extra commands:

```bash
./scripts/dev.sh logs    # tail logs from the running stack
./scripts/dev.sh reset   # stop and wipe all local data (clean first-run)
```

Access at `http://localhost:1337`.

**Verification checklist:**
- [ ] Strapi admin UI loads at `/admin`
- [ ] First-run account creation completes
- [ ] Data persists across `docker compose restart`
- [ ] Uploads directory survives restart
- [ ] `dev.sh reset` produces a clean first-run state

### Testing on a real Umbrel device

Use the sideload script to rsync `umbrelos/` directly to the device's app-store directory:

```bash
pnpm sideload                        # deploys to umbrel.local
./scripts/sideload.sh <host>         # deploys to a specific host
```

Then install or restart the app from the UmbrelOS dashboard.

## Persistent data

| Host path (relative to `APP_DATA_DIR`) | Purpose |
|---|---|
| `data/db/` | PostgreSQL database files |
| `data/uploads/` | Strapi media uploads |

Both directories are created by UmbrelOS before the containers start.

## Secrets

All secrets are derived deterministically from the per-installation `APP_SEED` in [umbrelos/exports.sh](umbrelos/exports.sh). They are stable across restarts and unique per Umbrel device — no manual secret management required.

## App Store submission

1. Fork [getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps)
2. Copy the contents of `umbrelos/` into a `strapi/` directory in the fork
3. Fill in the `submission` field in `umbrel-app.yml` with your PR URL
4. Open a pull request — maintainers will normalise image digests and review config

Gallery images (`1.png`, `2.png`, `3.png`) must be `1440×900px PNG`. The icon must be a `256×256 SVG` with no rounded corners (UmbrelOS applies its own corner radius).

## Database backups

UmbrelOS does not provide a built-in backup API. To back up your Strapi data, run a `pg_dump` against the PostgreSQL container:

```bash
docker exec strapi_db_1 pg_dump -U strapi strapi > strapi-backup.sql
```

Or copy the raw data directory from `${APP_DATA_DIR}/data/db/` when the database is stopped.
