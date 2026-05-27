#!/bin/bash
set -euo pipefail

# Runs the app locally in Docker, simulating the UmbrelOS runtime environment.
#
# Usage:
#   ./scripts/dev.sh              build image + start (foreground, Ctrl-C to stop)
#   ./scripts/dev.sh --no-build   skip image build, start with existing local image
#   ./scripts/dev.sh down         stop containers (keeps data)
#   ./scripts/dev.sh reset        stop containers and wipe all local data volumes
#   ./scripts/dev.sh logs         tail logs from the running stack

IMAGE="ghcr.io/nickchampion/strapi-umbrelos:latest"
DATA_DIR="$(pwd)/.dev-data"
COMPOSE="docker compose -f umbrelos/docker-compose.yml -f docker-compose.dev.yml"

# Derive secrets from APP_SEED exactly as UmbrelOS does via exports.sh
export APP_SEED="local-dev-seed-not-for-production"
export APP_DATA_DIR="$DATA_DIR"
export EXPORTS_APP_DIR="$DATA_DIR"
export APP_DOMAIN="localhost"

# Shim for the derive_entropy function that UmbrelOS app-script provides at runtime.
# Uses HMAC-SHA256 with APP_SEED as the key, matching the UmbrelOS implementation.
derive_entropy() {
  echo -n "${1}" | openssl dgst -sha256 -hmac "${APP_SEED}" | awk '{print $2}'
}
export -f derive_entropy

# shellcheck source=umbrelos/exports.sh
source umbrelos/exports.sh

CMD="${1:-}"

case "$CMD" in
  down)
    $COMPOSE down
    echo "✓ Stopped. Data is preserved in .dev-data/"
    exit 0
    ;;
  reset)
    $COMPOSE down --volumes
    rm -rf "$DATA_DIR"
    echo "✓ Stopped and wiped .dev-data/ — next start will be a clean first run."
    exit 0
    ;;
  logs)
    $COMPOSE logs -f
    exit 0
    ;;
esac

# Build (unless skipped)
if [[ "$CMD" != "--no-build" ]]; then
  echo "→ Building image..."
  docker build -t "$IMAGE" .
fi

# Create data directories that UmbrelOS would normally provision
mkdir -p \
  "$DATA_DIR/data/db" \
  "$DATA_DIR/data/uploads" \
  "$DATA_DIR/src"

echo ""
echo "  Admin panel → http://localhost:1337/admin"
echo "  API         → http://localhost:1337/api"
echo ""
echo "  Stop:  Ctrl-C  (data kept in .dev-data/)"
echo "  Reset: ./scripts/dev.sh reset"
echo ""

$COMPOSE up
