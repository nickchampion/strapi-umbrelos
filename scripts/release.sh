#!/bin/bash
set -euo pipefail

# Build and push a multi-arch image to GHCR, pin the digest in docker-compose.yml,
# then create a git version tag.
# Usage: ./scripts/release.sh <version>  (e.g. ./scripts/release.sh 5.46.1)
#
# One-time setup: echo "GITHUB_PAT" | docker login ghcr.io -u nickchampion --password-stdin

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: ./scripts/release.sh <version>  (e.g. 5.46.1)"
  exit 1
fi

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

echo "→ Committing docker-compose.yml digest update..."
git add umbrelos/docker-compose.yml
git commit -m "rel: ${TAG}"
git push origin main

echo "→ Tagging git commit as $TAG..."
git tag "$TAG"
git push origin "$TAG"

echo ""
echo "✓ Done."
echo "  ${IMAGE}:${TAG}@${DIGEST}"
