#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/backend/.env"
CLI="npx --yes supabase@2.100.1"

[ -f "$ENV_FILE" ] && source "$ENV_FILE"

if [ -z "${SUPABASE_PROJECT_REF:-}" ] && [ -n "${SUPABASE_URL:-}" ]; then
  SUPABASE_PROJECT_REF="$(printf '%s' "$SUPABASE_URL" | sed -E 's|https?://([^.]+)\.supabase\.co.*|\1|')"
fi

: "${SUPABASE_DB_PASSWORD:?export SUPABASE_DB_PASSWORD='DB비밀번호' 먼저}"

export SUPABASE_DB_PASSWORD
cd "$ROOT"

echo "Testing DB login (select 1)..."
$CLI db execute --linked --yes -p "$SUPABASE_DB_PASSWORD" --sql "select 1 as ok;"

echo "OK — 비밀번호가 맞습니다. 이제: bash scripts/supabase-push.sh"
