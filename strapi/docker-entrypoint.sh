#!/bin/sh
set -e

# Fix uploads dir permissions — Docker may create it as root on first run
mkdir -p /opt/app/public/uploads
chown node:node /opt/app/public/uploads

# On first run with a mounted src/ volume, populate from image defaults
# so the example content types and config persist across container restarts
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

# Ensure email-settings plugin source exists — tsc incremental mode deletes dist/
# output files when their source is absent, so we must keep the src in sync.
if [ ! -f /opt/app/src/plugins/email-settings/server/src/index.ts ]; then
    echo "→ Copying email-settings plugin from defaults..."
    mkdir -p /opt/app/src/plugins/email-settings
    cp -rp /opt/app-src-default/plugins/email-settings/. \
       /opt/app/src/plugins/email-settings/
    chown -R node:node /opt/app/src/plugins/email-settings
fi

# Clear Vite / admin build cache so the panel rebuilds cleanly on every start.
rm -rf /opt/app/.cache/*

exec su-exec node "$@"
