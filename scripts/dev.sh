#!/bin/bash
set -euo pipefail

# Local dev/test script — simulates the UmbrelOS runtime environment.
# Usage:
#   ./dev.sh            build image + start all services
#   ./dev.sh --no-build skip the docker build step (use existing local image)
#   ./dev.sh down       tear down containers and remove volumes

IMAGE="ghcr.io/nickchampion/strapi-umbrelos:latest"
DATA_DIR="$(pwd)/.dev-data"

COMPOSE="docker compose -f umbrelos/docker-compose.yml -f docker-compose.dev.yml"

# ── Derive secrets from APP_SEED (same as UmbrelOS does via exports.sh) ────────
export APP_SEED="local-dev-seed-not-for-production"
export APP_DATA_DIR="$DATA_DIR"
export APP_DOMAIN="localhost:1337"
# shellcheck source=umbrelos/exports.sh
source umbrelos/exports.sh

# ── Tear-down shortcut ─────────────────────────────────────────────────────────
if [[ "${1:-}" == "down" ]]; then
  $COMPOSE down --volumes
  echo "✓ Stopped and removed containers + volumes."
  exit 0
fi

# ── Build ──────────────────────────────────────────────────────────────────────
if [[ "${1:-}" != "--no-build" ]]; then
  echo "→ Building image ($IMAGE)..."
  docker build -t "$IMAGE" .
fi

# ── Data directories (UmbrelOS creates these before first start) ───────────────
mkdir -p "$DATA_DIR/data/db" "$DATA_DIR/data/uploads"

# ── Start ──────────────────────────────────────────────────────────────────────
echo "→ Starting services..."
echo "   Admin panel: http://localhost:1337/admin"
echo "   API:         http://localhost:1337/api"
echo ""

$COMPOSE up ${@+"$@"}
