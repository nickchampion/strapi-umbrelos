#!/bin/bash

# exports.sh is sourced by app-script BEFORE APP_SEED and APP_DATA_DIR are set
# in the environment. We therefore derive the app seed ourselves using the same
# derive_entropy function that app-script defines, and use EXPORTS_APP_DIR
# (set by app-script in the sourcing loop) in place of APP_DATA_DIR.
_app_seed=$(derive_entropy "app-strapi-seed")

export APP_STRAPI_PORT="1337"

export APP_STRAPI_DB_PASSWORD="$(echo "${_app_seed}strapi-db" | sha256sum | head -c 32)"

# APP_KEYS is a comma-separated list of session signing keys
export APP_STRAPI_APP_KEYS="$(echo "${_app_seed}strapi-key1" | sha256sum | head -c 32),$(echo "${_app_seed}strapi-key2" | sha256sum | head -c 32)"

export APP_STRAPI_API_TOKEN_SALT="$(echo "${_app_seed}strapi-api-token" | sha256sum | head -c 32)"

export APP_STRAPI_ADMIN_JWT_SECRET="$(echo "${_app_seed}strapi-admin-jwt" | sha256sum | head -c 64)"

export APP_STRAPI_JWT_SECRET="$(echo "${_app_seed}strapi-jwt" | sha256sum | head -c 64)"

export APP_STRAPI_TRANSFER_TOKEN_SALT="$(echo "${_app_seed}strapi-transfer" | sha256sum | head -c 32)"

export APP_STRAPI_ENCRYPTION_KEY="$(echo "${_app_seed}strapi-encryption" | sha256sum | head -c 32)"

# SMTP settings — stored in persistent app data so they survive app updates.
# Written by scripts/configure-smtp.sh; absent means email is disabled.
APP_STRAPI_SMTP_HOST=""
APP_STRAPI_SMTP_PORT="587"
APP_STRAPI_SMTP_USERNAME=""
APP_STRAPI_SMTP_PASSWORD=""
APP_STRAPI_SMTP_FROM=""
APP_STRAPI_SMTP_REPLY_TO=""
SMTP_CONFIG="${EXPORTS_APP_DIR}/config/smtp.env"
if [ -f "$SMTP_CONFIG" ]; then
    # shellcheck source=/dev/null
    source "$SMTP_CONFIG"
fi
export APP_STRAPI_SMTP_HOST
export APP_STRAPI_SMTP_PORT
export APP_STRAPI_SMTP_USERNAME
export APP_STRAPI_SMTP_PASSWORD
export APP_STRAPI_SMTP_FROM
export APP_STRAPI_SMTP_REPLY_TO
