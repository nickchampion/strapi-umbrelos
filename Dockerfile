# syntax=docker/dockerfile:1

# ── Build stage ────────────────────────────────────────────────────────────────
FROM node:22-alpine AS build

# vips-dev is required by sharp (image processing)
RUN apk update && apk add --no-cache vips-dev

WORKDIR /opt/app

COPY strapi/package.json ./

RUN npm config set fetch-retry-maxtimeout 600000 -g && npm install

COPY strapi/ .

ENV NODE_ENV=production

RUN npm run build

# Prune to production deps while we still have the compiled output
RUN npm prune --omit=dev

# ── Runtime stage ──────────────────────────────────────────────────────────────
FROM node:22-alpine AS runtime

# su-exec for privilege dropping in entrypoint
RUN apk update && apk upgrade --no-cache && apk add --no-cache vips-dev su-exec

ENV NODE_ENV=production

WORKDIR /opt/app

COPY --from=build /opt/app ./

# Save default src/ so the entrypoint can populate a fresh volume on first run
RUN cp -rp src /opt/app-src-default

COPY strapi/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p .tmp .cache public/uploads && \
    chown -R node:node /opt/app

EXPOSE 1337

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:1337/_health || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npm", "run", "develop"]
