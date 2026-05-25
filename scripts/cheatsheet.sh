#!/bin/bash
# Cheat sheet — copy and run individual commands as needed.

# ── SSH ──────────────────────────────────────────────────────────────────────
ssh umbrel@umbrel.netbird.cloud

# ── Sideload & local dev ─────────────────────────────────────────────────────
pnpm sideload                # sync umbrelos/ files to device
pnpm dev                     # start local docker compose stack
pnpm dev:fresh               # start without rebuilding image
pnpm dev:down                # stop local stack
pnpm release 5.x.x           # build + push multi-arch image, tag + commit

# ── umbreld CLI (run on device) ───────────────────────────────────────────────
umbreld client apps.state.query --appId strapi
umbreld client apps.install.mutate --appId strapi
umbreld client apps.uninstall.mutate --appId strapi
umbreld client apps.restart.mutate --appId strapi
umbreld client apps.list.query

# ── Docker — containers ───────────────────────────────────────────────────────
docker ps                                      # running containers
docker ps -a                                   # all including stopped
docker ps -a | grep strapi                     # filter by app
docker inspect strapi_web_1                    # full container config
docker stats                                   # live CPU/mem

# ── Docker — logs ─────────────────────────────────────────────────────────────
docker logs strapi_web_1 --tail 100
docker logs strapi_web_1 --tail 100 -f         # follow live
docker logs strapi_db_1 --tail 50
docker logs strapi_web_1 --since 10m
docker logs strapi_web_1 2>&1 | grep -i error

# ── Docker — images ───────────────────────────────────────────────────────────
docker images | grep strapi
docker pull ghcr.io/nickchampion/strapi-umbrelos:v1.0.2   # test pull / auth check
docker image inspect ghcr.io/nickchampion/strapi-umbrelos:v1.0.2 --format='{{index .RepoDigests 0}}'
docker system prune                            # clean stopped containers + dangling images

# ── Docker — exec into container ──────────────────────────────────────────────
docker exec -it strapi_web_1 sh
docker exec -it strapi_db_1 psql -U strapi -d strapi
docker exec strapi_db_1 pg_isready -U strapi -d strapi

# ── GHCR ──────────────────────────────────────────────────────────────────────
# One-time login
echo "YOUR_PAT" | docker login ghcr.io -u nickchampion --password-stdin

# Build + push multi-arch (Apple Silicon)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/nickchampion/strapi-umbrelos:vX.X.X \
  --push \
  --metadata-file /tmp/meta.json \
  .
jq -r '."containerimage.digest"' /tmp/meta.json   # pin this digest in docker-compose.yml

# ── UmbrelOS — logs & diagnostics ─────────────────────────────────────────────
journalctl -u umbreld -n 100 --no-pager
journalctl -u umbreld -f
journalctl -u umbreld -n 500 --no-pager | grep -i "strapi\|error\|fail"
docker events --since 10m --filter name=strapi

# ── UmbrelOS — file paths ─────────────────────────────────────────────────────
# App definition (sideload destination)
# /home/umbrel/umbrel/app-stores/getumbrel-umbrel-apps-github-53f74447/strapi/
#
# App persistent data
# /home/umbrel/umbrel/app-data/strapi/
