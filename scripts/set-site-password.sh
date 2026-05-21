#!/usr/bin/env bash
# Set site access password on Vercel frontend (SITE_PASSWORD).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASSWORD="${1:-}"

if [ -z "$PASSWORD" ]; then
  echo "Usage: bash scripts/set-site-password.sh 'your-password'"
  exit 1
fi

vercel whoami >/dev/null 2>&1 || vercel login

cd "$ROOT/frontend"
if vercel env ls production 2>/dev/null | grep -qE '^[[:space:]]*SITE_PASSWORD[[:space:]]'; then
  printf '%s' "$PASSWORD" | vercel env update SITE_PASSWORD production
else
  printf '%s' "$PASSWORD" | vercel env add SITE_PASSWORD production
fi

echo "SITE_PASSWORD 설정 완료. 프론트 재배포 중..."
vercel deploy --prod --yes
echo "Done: https://ipo-radar-frontend.vercel.app (비밀번호 필요)"
