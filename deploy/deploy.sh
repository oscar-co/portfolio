#!/usr/bin/env bash
set -Eeuo pipefail

readonly RELEASE_TAG="${1:-}"
readonly PROJECT_PATH="/opt/portfolio/app"
readonly REPO_URL="https://github.com/oscar-co/portfolio.git"
readonly DEPLOY_DIR="/var/www/oscarqa.es/portfolio"
readonly HEALTH_URL="http://127.0.0.1:8001/health"

if [[ ! "$RELEASE_TAG" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  echo "ERROR: A valid release tag is required (for example, v1.2.0)." >&2
  exit 1
fi

echo "==> Starting portfolio deployment for $RELEASE_TAG"

mkdir -p "$(dirname "$PROJECT_PATH")"
mkdir -p "$DEPLOY_DIR"

if [[ ! -d "$PROJECT_PATH/.git" ]]; then
  echo "==> Cloning repository into $PROJECT_PATH"
  git clone --no-checkout "$REPO_URL" "$PROJECT_PATH"
else
  echo "==> Preparing repository in $PROJECT_PATH"
  git -C "$PROJECT_PATH" remote set-url origin "$REPO_URL"
fi

echo "==> Fetching $RELEASE_TAG and the production branch"
git -C "$PROJECT_PATH" fetch --no-tags \
  --no-prune origin refs/heads/main:refs/deploy/main
git -C "$PROJECT_PATH" fetch --no-prune --no-tags \
  origin "refs/tags/$RELEASE_TAG:refs/tags/$RELEASE_TAG"

readonly RELEASE_COMMIT="$(git -C "$PROJECT_PATH" rev-parse --verify "$RELEASE_TAG^{commit}")"

if ! git -C "$PROJECT_PATH" merge-base --is-ancestor "$RELEASE_COMMIT" refs/deploy/main; then
  echo "ERROR: $RELEASE_TAG does not point to a commit included in main." >&2
  exit 1
fi

echo "==> Checking out $RELEASE_TAG ($RELEASE_COMMIT)"
git -C "$PROJECT_PATH" checkout --detach "$RELEASE_COMMIT"
git -C "$PROJECT_PATH" reset --hard "$RELEASE_COMMIT"

if [[ ! -f "$PROJECT_PATH/compose.prod.yml" ]]; then
  echo "ERROR: compose.prod.yml not found in $PROJECT_PATH" >&2
  exit 1
fi

if [[ ! -f "$PROJECT_PATH/Dockerfile" ]]; then
  echo "ERROR: Dockerfile not found in $PROJECT_PATH" >&2
  exit 1
fi

echo "==> Copying application files to $DEPLOY_DIR"
rsync \
  --archive \
  --delete \
  --exclude=".git/" \
  --exclude=".github/" \
  --exclude=".venv/" \
  --exclude="__pycache__/" \
  --exclude="*.pyc" \
  --exclude=".mypy_cache/" \
  --exclude=".pytest_cache/" \
  --exclude=".DS_Store" \
  --exclude="TODO.md" \
  "$PROJECT_PATH/" "$DEPLOY_DIR/"

cd "$DEPLOY_DIR"

echo "==> Building and starting container for $RELEASE_TAG"
docker compose \
  --project-name portfolio \
  --file compose.prod.yml \
  up \
  --detach \
  --build \
  --remove-orphans

echo "==> Waiting for health check"
for attempt in {1..20}; do
  if curl --fail --silent "$HEALTH_URL" >/dev/null; then
    echo "==> Portfolio $RELEASE_TAG is healthy"
    docker image prune --force >/dev/null
    echo "==> Deployment completed"
    exit 0
  fi

  echo "==> Health check attempt $attempt/20 failed"
  sleep 2
done

echo "ERROR: Portfolio failed its health check" >&2
docker compose \
  --project-name portfolio \
  --file compose.prod.yml \
  ps
docker compose \
  --project-name portfolio \
  --file compose.prod.yml \
  logs \
  --tail=100
exit 1
