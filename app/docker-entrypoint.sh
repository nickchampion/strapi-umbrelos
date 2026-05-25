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

exec su-exec node "$@"
