#!/usr/bin/env bash
# Apply schema via Supabase Management API (no DB password).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SQL_FILE="$ROOT/supabase/migrations/000_combined_for_dashboard.sql"
ENV_FILE="$ROOT/backend/.env"

[ -f "$ENV_FILE" ] && source "$ENV_FILE"

if [ -z "${SUPABASE_PROJECT_REF:-}" ] && [ -n "${SUPABASE_URL:-}" ]; then
  SUPABASE_PROJECT_REF="$(printf '%s' "$SUPABASE_URL" | sed -E 's|https?://([^.]+)\.supabase\.co.*|\1|')"
fi

: "${SUPABASE_ACCESS_TOKEN:?export SUPABASE_ACCESS_TOKEN='sbp_...' (Dashboard → Account → Access Tokens)}"
: "${SUPABASE_PROJECT_REF:?project ref required}"

export SUPABASE_ACCESS_TOKEN SUPABASE_PROJECT_REF SQL_FILE

python3 <<PY
import json
import os
import urllib.error
import urllib.request

ref = os.environ["SUPABASE_PROJECT_REF"]
token = os.environ["SUPABASE_ACCESS_TOKEN"]
sql_path = os.environ["SQL_FILE"]

with open(sql_path, encoding="utf-8") as f:
    query = f.read()

# Drop comment-only header lines for cleaner logs
lines = [ln for ln in query.splitlines() if not ln.strip().startswith("--")]
query = "\n".join(lines).strip()

url = f"https://api.supabase.com/v1/projects/{ref}/database/query"
body = json.dumps({"query": query}).encode("utf-8")
req = urllib.request.Request(
    url,
    data=body,
    method="POST",
    headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    },
)

try:
    with urllib.request.urlopen(req, timeout=120) as resp:
        print("OK", resp.status)
        data = resp.read().decode("utf-8", errors="replace")
        if data.strip():
            print(data[:500])
except urllib.error.HTTPError as e:
    err = e.read().decode("utf-8", errors="replace")
    print(f"HTTP {e.code}: {err}", file=os.sys.stderr)
    if e.code == 403 and "1010" in err:
        print("", file=os.sys.stderr)
        print("Cloudflare(1010) 차단 — CLI/API 대신 SQL Editor 사용:", file=os.sys.stderr)
        print("  https://supabase.com/dashboard/project/qghquidouqdrjxdjyrgy/sql/new", file=os.sys.stderr)
        print("  파일: supabase/migrations/000_combined_for_dashboard.sql 전체 붙여넣기 → Run", file=os.sys.stderr)
    raise SystemExit(1)
PY

echo "Done. Table Editor에서 settings, ipo_items 확인하세요."
