#!/bin/sh
set -e

# Fix uploads dir permissions — Docker may create it as root on first run
mkdir -p /opt/app/public/uploads
chown node:node /opt/app/public/uploads

# On first run with a mounted src/ volume, populate from image defaults
# so content types and config persist across container restarts
if [ ! -f /opt/app/src/index.ts ]; then
    echo "→ First run: initialising src/ from image defaults..."
    cp -rp /opt/app-src-default/. /opt/app/src/
    chown -R node:node /opt/app/src
else
    # Sync managed directories from the image on every start so that plugin
    # and admin updates propagate to existing installs. User content types
    # and config live outside admin/ and plugins/ and are never touched.
    mkdir -p /opt/app/src/admin /opt/app/src/plugins
    cp -rp /opt/app-src-default/admin/.   /opt/app/src/admin/
    cp -rp /opt/app-src-default/plugins/. /opt/app/src/plugins/
    chown -R node:node /opt/app/src/admin /opt/app/src/plugins
fi

# Clear Vite / admin build cache so the panel rebuilds cleanly on every start.
rm -rf /opt/app/.cache/*

# Determine run mode from the persistent mode file written by the Run Mode plugin.
# Default (no file) is development so users can create content types on first install.
MODE_FILE="/opt/app/src/.strapi-run-mode"
RUN_MODE="development"
if [ -f "$MODE_FILE" ]; then
    RUN_MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
fi

if [ "$RUN_MODE" = "production" ]; then
    echo "→ Run mode: production (strapi start)"
    export NODE_ENV=production
    exec su-exec node npm run start
else
    echo "→ Run mode: development (strapi develop)"
    export NODE_ENV=development
    exec su-exec node npm run develop
fi
