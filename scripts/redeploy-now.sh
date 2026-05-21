#!/usr/bin/env bash
# Deploy local code (api URL + CORS fixes) to Vercel production.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

vercel whoami >/dev/null 2>&1 || vercel login

echo "==> Backend"
cd "$ROOT/backend"
vercel deploy --prod --yes

echo "==> Frontend"
cd "$ROOT/frontend"
vercel deploy --prod --yes

echo ""
echo "Open: https://ipo-radar-frontend.vercel.app"
echo "Test: curl https://ipo-radar-backend.vercel.app/api/health"
