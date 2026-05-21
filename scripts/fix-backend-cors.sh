#!/usr/bin/env bash
# Fix: FUNCTION_INVOCATION_FAILED — CORS_ORIGIN must be explicitly configured in production
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URLS_FILE="$ROOT/.deploy-urls.txt"

if [ ! -f "$URLS_FILE" ]; then
  echo "ERROR: $URLS_FILE 없음. frontend URL을 인자로 주세요." >&2
  echo "  예: bash scripts/fix-backend-cors.sh https://ipo-radar-frontend-xxx.vercel.app" >&2
  exit 1
fi

FRONTEND_URL="$(grep '^frontend=' "$URLS_FILE" | cut -d= -f2-)"
FRONTEND_URL="${1:-$FRONTEND_URL}"
CORS_ORIGIN="https://ipo-radar-frontend.vercel.app"
if [ -n "$FRONTEND_URL" ] && [ "$FRONTEND_URL" != "$CORS_ORIGIN" ]; then
  CORS_ORIGIN="$CORS_ORIGIN,$FRONTEND_URL"
fi

cd "$ROOT/backend"
vercel whoami >/dev/null || vercel login

if vercel env ls production 2>/dev/null | grep -qE '^[[:space:]]*CORS_ORIGIN[[:space:]]'; then
  printf '%s' "$CORS_ORIGIN" | vercel env update CORS_ORIGIN production
else
  printf '%s' "$CORS_ORIGIN" | vercel env add CORS_ORIGIN production
fi

echo "CORS_ORIGIN=$CORS_ORIGIN"
vercel deploy --prod --yes
echo "Done. Test: curl $(grep '^backend=' "$URLS_FILE" | cut -d= -f2-)/api/health"
