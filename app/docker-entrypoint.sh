#!/bin/sh
set -e

# Fix uploads dir permissions — Docker may create it as root on first run
mkdir -p /opt/app/public/uploads
chown node:node /opt/app/public/uploads

# On first run with a mounted src/ volume, populate from image defaults
# so content types created via the UI persist across container restarts
if [ ! -f /opt/app/src/index.ts ]; then
    echo "→ First run: initialising src/ from image defaults..."
    cp -rp /opt/app-src-default/. /opt/app/src/
    chown -R node:node /opt/app/src
fi

# Ensure the Vite config exists — needed for allowedHosts on upgrades
if [ ! -f /opt/app/src/admin/vite.config.ts ]; then
    mkdir -p /opt/app/src/admin
    cp /opt/app-src-default/admin/vite.config.ts /opt/app/src/admin/vite.config.ts
    chown -R node:node /opt/app/src/admin
fi

# Clear TypeScript compilation cache so Strapi recompiles cleanly on every start.
# Without this, stale cache from a previous run causes crashes after content type changes.
rm -rf /opt/app/.cache/*

exec su-exec node "$@"
