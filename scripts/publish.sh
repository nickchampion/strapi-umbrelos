#!/bin/bash
set -euo pipefail

# Build and push a multi-arch image to GHCR, pin the digest in docker-compose.yml,
# then create a git version tag.
#
# Reads the current version from umbrelos/umbrel-app.yml, bumps the revision
# (last) segment, writes it back, and releases that version. No arguments needed.
# Usage: ./scripts/publish.sh
#
# One-time setup: echo "GITHUB_PAT" | docker login ghcr.io -u nickchampion --password-stdin

APP_YML="umbrelos/umbrel-app.yml"

CURRENT_VERSION=$(sed -n 's/^version:[[:space:]]*"\{0,1\}\([0-9.]*\)"\{0,1\}[[:space:]]*$/\1/p' "$APP_YML")
if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Could not read version from $APP_YML"
  exit 1
fi

MAJOR="${CURRENT_VERSION%%.*}"
REVISION="${CURRENT_VERSION##*.}"
MINOR="${CURRENT_VERSION#*.}"; MINOR="${MINOR%.*}"
VERSION="${MAJOR}.${MINOR}.$((REVISION + 1))"

echo "→ Bumping version ${CURRENT_VERSION} → ${VERSION} in $APP_YML..."
sed -i '' "s|^version:.*|version: \"${VERSION}\"|" "$APP_YML"

IMAGE="ghcr.io/nickchampion/strapi-umbrelos"
TAG="v${VERSION}"
METADATA_FILE="$(mktemp)"

echo "→ Building and pushing multi-arch image ($TAG)..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "${IMAGE}:${TAG}" \
  -t "${IMAGE}:latest" \
  --push \
  --metadata-file "$METADATA_FILE" \
  .
  
DIGEST=$(jq -r '."containerimage.digest"' "$METADATA_FILE")
rm "$METADATA_FILE"

echo "→ Pinning digest in umbrelos/docker-compose.yml..."
sed -i '' \
  "s|image: ${IMAGE}.*|image: ${IMAGE}:${TAG}@${DIGEST}|" \
  umbrelos/docker-compose.yml

echo "→ Committing version bump and digest update..."
git add .
git commit -m "rel: ${TAG}"
git push origin main

echo "→ Tagging git commit as $TAG..."
git tag "$TAG"
git push origin "$TAG"

echo ""
echo "✓ Done."
echo "  ${IMAGE}:${TAG}@${DIGEST}"
