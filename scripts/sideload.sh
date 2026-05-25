#!/bin/bash
set -euo pipefail

# Sync app files to the UmbrelOS app-store directory so umbreld can install it.
# https://github.com/getumbrel/umbrel-apps#32-test-using-umbrelos-running-on-a-physical-device
#
# Usage:
#   ./scripts/sideload.sh              deploy to umbrel.local
#   ./scripts/sideload.sh <host>       deploy to a specific host

UMBREL_HOST="${1:-umbrel.local}"
APP_ID="strapi"
REMOTE="umbrel@${UMBREL_HOST}"
REMOTE_APP_DIR="/home/umbrel/umbrel/app-stores/getumbrel-umbrel-apps-github-53f74447/${APP_ID}"

echo "→ Syncing app files to ${REMOTE}:${REMOTE_APP_DIR}..."
rsync -av --exclude=".gitkeep" umbrelos/ "${REMOTE}:${REMOTE_APP_DIR}/"

echo ""
echo "✓ Done. Install or restart the app from the UmbrelOS dashboard."
