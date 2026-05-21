#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEAM_SLUG="${VERCEL_TEAM:-ddo-d}"
BACKEND_PROJECT="${VERCEL_BACKEND_PROJECT:-ipo-radar-backend}"
FRONTEND_PROJECT="${VERCEL_FRONTEND_PROJECT:-ipo-radar-frontend}"

die() { echo "ERROR: $*" >&2; exit 1; }

if ! vercel whoami >/dev/null 2>&1; then
  echo "Vercel 로그인이 필요합니다."
  vercel login || die "vercel login 실패"
fi

env_upsert() {
  local name="$1" value="$2"
  if vercel env ls production 2>/dev/null | grep -qE "^[[:space:]]*${name}[[:space:]]"; then
    printf '%s' "$value" | vercel env update "$name" production
  else
    printf '%s' "$value" | vercel env add "$name" production
  fi
}

echo "==> Backend"
cd "$ROOT/backend"
vercel link --yes --scope "$TEAM_SLUG" --project "$BACKEND_PROJECT"

if [ -f "$ROOT/backend/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT/backend/.env"
  set +a
fi

: "${SUPABASE_URL:?backend/.env 에 SUPABASE_URL 필요}"
: "${SUPABASE_SECRET_KEY:?backend/.env 에 SUPABASE_SECRET_KEY 필요}"

CRON_SECRET="${CRON_SECRET:-$(openssl rand -hex 32)}"
ADMIN_KEY="${ADMIN_KEY:-$(openssl rand -hex 24)}"

env_upsert NODE_ENV production
env_upsert READ_ONLY true
env_upsert SUPABASE_URL "$SUPABASE_URL"
env_upsert SUPABASE_SECRET_KEY "$SUPABASE_SECRET_KEY"
env_upsert CRON_SECRET "$CRON_SECRET"
env_upsert ADMIN_KEY "$ADMIN_KEY"
# NODE_ENV=production requires CORS_ORIGIN before the first backend deploy.
FRONTEND_ORIGIN="${FRONTEND_ORIGIN:-https://${FRONTEND_PROJECT}.vercel.app}"
env_upsert CORS_ORIGIN "$FRONTEND_ORIGIN"

BACKEND_URL="$(vercel deploy --prod --yes)"
echo "Backend URL: $BACKEND_URL"

echo "==> Frontend"
cd "$ROOT/frontend"
vercel link --yes --scope "$TEAM_SLUG" --project "$FRONTEND_PROJECT"
env_upsert VITE_API_BASE_URL "$BACKEND_URL"
FRONTEND_URL="$(vercel deploy --prod --yes)"
echo "Frontend URL: $FRONTEND_URL"

echo "==> Backend CORS (include deployment URL)"
cd "$ROOT/backend"
CORS_ORIGINS="$FRONTEND_ORIGIN"
if [ "$FRONTEND_URL" != "$FRONTEND_ORIGIN" ]; then
  CORS_ORIGINS="$FRONTEND_ORIGIN,$FRONTEND_URL"
fi
env_upsert CORS_ORIGIN "$CORS_ORIGINS"
vercel deploy --prod --yes >/dev/null

cat >"$ROOT/.deploy-urls.txt" <<EOF
frontend=$FRONTEND_URL
backend=$BACKEND_URL
admin_key=$ADMIN_KEY
EOF

echo ""
echo "배포 완료"
echo "  Frontend: $FRONTEND_URL"
echo "  Backend:  $BACKEND_URL"
echo "  ADMIN_KEY: $ADMIN_KEY (프론트 설정 탭에 입력)"
echo "  저장: $ROOT/.deploy-urls.txt"
