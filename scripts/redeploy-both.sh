#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
vercel whoami >/dev/null 2>&1 || vercel login
echo "Backend..."
(cd "$ROOT/backend" && vercel deploy --prod --yes)
echo "Frontend..."
(cd "$ROOT/frontend" && vercel deploy --prod --yes)
echo "Done: https://ipo-radar-frontend.vercel.app"
