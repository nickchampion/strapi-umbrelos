#!/bin/bash

# All secrets are derived deterministically from the per-installation APP_SEED.
# This means secrets survive container restarts and are unique per Umbrel device.

export APP_STRAPI_PORT="1337"

export APP_STRAPI_DB_PASSWORD="$(echo "${APP_SEED}strapi-db" | sha256sum | head -c 32)"

# APP_KEYS is a comma-separated list of session signing keys
export APP_STRAPI_APP_KEYS="$(echo "${APP_SEED}strapi-key1" | sha256sum | head -c 32),$(echo "${APP_SEED}strapi-key2" | sha256sum | head -c 32)"

export APP_STRAPI_API_TOKEN_SALT="$(echo "${APP_SEED}strapi-api-token" | sha256sum | head -c 32)"

export APP_STRAPI_ADMIN_JWT_SECRET="$(echo "${APP_SEED}strapi-admin-jwt" | sha256sum | head -c 64)"

export APP_STRAPI_JWT_SECRET="$(echo "${APP_SEED}strapi-jwt" | sha256sum | head -c 64)"

export APP_STRAPI_TRANSFER_TOKEN_SALT="$(echo "${APP_SEED}strapi-transfer" | sha256sum | head -c 32)"

export APP_STRAPI_ENCRYPTION_KEY="$(echo "${APP_SEED}strapi-encryption" | sha256sum | head -c 32)"
