#!/usr/bin/env bash
# Set VITE_API_BASE_URL on Vercel (frontend) and redeploy.
set -euo pipefail

API_URL="https://ipo-radar-backend.vercel.app"
# 구 배포 URL(500 발생) 예: ipo-radar-backend-gi4ya0d0x-ddo-d.vercel.app — 사용 금지
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

vercel whoami >/dev/null 2>&1 || vercel login

cd "$ROOT/frontend"
if vercel env ls production 2>/dev/null | grep -qE '^[[:space:]]*VITE_API_BASE_URL[[:space:]]'; then
  printf '%s' "$API_URL" | vercel env update VITE_API_BASE_URL production
  echo "Updated VITE_API_BASE_URL"
else
  printf '%s' "$API_URL" | vercel env add VITE_API_BASE_URL production
  echo "Added VITE_API_BASE_URL"
fi

vercel deploy --prod --yes
echo "Done: https://ipo-radar-frontend.vercel.app"
