#!/usr/bin/env bash
# Fix browser "Failed to fetch" — redeploy backend + frontend with API proxy/CORS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_URL="https://ipo-radar-backend.vercel.app"
FRONTEND_URL="https://ipo-radar-frontend.vercel.app"
CORS_ORIGIN="$FRONTEND_URL,https://ipo-radar-frontend-ddo-d.vercel.app,https://ipo-radar-frontend-ekswkd01-9322-ddo-d.vercel.app"

vercel whoami >/dev/null 2>&1 || vercel login

echo "==> Backend env + deploy"
cd "$ROOT/backend"
if vercel env ls production 2>/dev/null | grep -qE '^[[:space:]]*CORS_ORIGIN[[:space:]]'; then
  printf '%s' "$CORS_ORIGIN" | vercel env update CORS_ORIGIN production
else
  printf '%s' "$CORS_ORIGIN" | vercel env add CORS_ORIGIN production
fi
vercel deploy --prod --yes

echo "==> Frontend deploy (vercel.json rewrites /api -> backend)"
cd "$ROOT/frontend"
if vercel env ls production 2>/dev/null | grep -qE '^[[:space:]]*VITE_API_BASE_URL[[:space:]]'; then
  printf '%s' "$BACKEND_URL" | vercel env update VITE_API_BASE_URL production
else
  printf '%s' "$BACKEND_URL" | vercel env add VITE_API_BASE_URL production
fi
vercel deploy --prod --yes

cat >"$ROOT/.deploy-urls.txt" <<EOF
frontend=$FRONTEND_URL
backend=$BACKEND_URL
EOF

echo ""
echo "Done."
echo "  Frontend: $FRONTEND_URL"
echo "  Backend:  $BACKEND_URL"
echo "  Test: curl $BACKEND_URL/api/health"
echo "  Test: curl $BACKEND_URL/api/health"
echo "  (프론트 /api 프록시는 frontend 재배포 후: curl $FRONTEND_URL/api/health)"
