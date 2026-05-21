#!/usr/bin/env bash
# Link remote Supabase project and apply migrations (IPv4-friendly pooler).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/backend/.env"
CLI="npx --yes supabase@2.100.1"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$ENV_FILE"
  set +a
fi

if [ -n "${SUPABASE_DB_PASSWORD_FILE:-}" ] && [ -f "$SUPABASE_DB_PASSWORD_FILE" ]; then
  SUPABASE_DB_PASSWORD="$(tr -d '\r\n' <"$SUPABASE_DB_PASSWORD_FILE")"
  export SUPABASE_DB_PASSWORD
fi

if [ -z "${SUPABASE_PROJECT_REF:-}" ] && [ -n "${SUPABASE_URL:-}" ]; then
  SUPABASE_PROJECT_REF="$(printf '%s' "$SUPABASE_URL" | sed -E 's|https?://([^.]+)\.supabase\.co.*|\1|')"
fi

: "${SUPABASE_ACCESS_TOKEN:?Supabase Access Token 필요. Dashboard → Account → Access Tokens}"
: "${SUPABASE_PROJECT_REF:?SUPABASE_PROJECT_REF 또는 backend/.env 의 SUPABASE_URL 필요}"
: "${SUPABASE_DB_PASSWORD:?Database password 필요. Settings → Database → Reset 후 export SUPABASE_DB_PASSWORD='...'}"

export SUPABASE_ACCESS_TOKEN
export SUPABASE_DB_PASSWORD
unset SUPABASE_DB_URL

cd "$ROOT"
rm -rf "$ROOT/supabase/.temp"

echo "==> link (pooler / IPv4) project-ref: $SUPABASE_PROJECT_REF"
$CLI link --project-ref "$SUPABASE_PROJECT_REF" --password "$SUPABASE_DB_PASSWORD" --yes

echo "==> test password"
if ! $CLI db execute --linked --yes -p "$SUPABASE_DB_PASSWORD" --sql "select 1 as ok;"; then
  echo "" >&2
  echo "ERROR: DB 비밀번호가 틀립니다." >&2
  echo "  • sb_secret / anon key 가 아닌 **Database password** 인지 확인" >&2
  echo "  • https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/settings/database" >&2
  echo "  • Reset database password → 새 비밀번호를 파일로 저장:" >&2
  echo "      pbpaste > ~/.supabase-db-pass && chmod 600 ~/.supabase-db-pass" >&2
  echo "      export SUPABASE_DB_PASSWORD_FILE=~/.supabase-db-pass" >&2
  echo "  • 또는 SQL Editor: supabase/migrations/000_combined_for_dashboard.sql 실행" >&2
  exit 1
fi

echo "==> db push"
$CLI db push --linked --yes -p "$SUPABASE_DB_PASSWORD"

echo "Done. Tables: settings, ipo_items, fetch_logs, anchors"
