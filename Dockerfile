# syntax=docker/dockerfile:1

# ── Build stage ────────────────────────────────────────────────────────────────
FROM node:22-alpine AS build

RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    vips-dev \
    bash \
    git

WORKDIR /opt/

COPY app/package.json app/package-lock.json* ./

RUN npm install -g node-gyp
RUN npm config set fetch-retry-maxtimeout 600000 -g && npm install

ENV PATH=/opt/node_modules/.bin:$PATH

WORKDIR /opt/app

COPY app/ .

ENV NODE_ENV=production

RUN npm run build

# ── Runtime stage ──────────────────────────────────────────────────────────────
FROM node:22-alpine AS runtime

RUN apk update && apk upgrade --no-cache && apk add --no-cache vips-dev

ENV NODE_ENV=production

WORKDIR /opt/

COPY --from=build /opt/package.json ./

RUN npm install --omit=dev && npm cache clean --force

ENV PATH=/opt/node_modules/.bin:$PATH

WORKDIR /opt/app

COPY --from=build /opt/app ./

RUN mkdir -p .tmp .cache && \
    chown -R node:node /opt/app

USER node

EXPOSE 1337

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:1337/_health || exit 1

CMD ["npm", "run", "start"]
