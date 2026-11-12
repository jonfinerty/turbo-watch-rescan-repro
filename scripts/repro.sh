#!/usr/bin/env bash
# Usage: ./scripts/repro.sh [trials]
# Each trial starts `turbo watch build`, waits for the first build, writes and deletes
# 100,000 files in the gitignored apps/app-a/.cache/, then counts the full-rescan
# errors and the builds that turbo ran after the burst.
set -eu
cd "$(dirname "$0")/.."
trials=${1:-8}
hits=0

for t in $(seq "$trials"); do
  log=$(mktemp)
  pnpm exec turbo watch build -vv >"$log" 2>&1 &
  turbo=$!
  sleep 8
  builds_before=$(grep -c 'Application A is built!' "$log" || true)

  node scripts/burst.mjs
  sleep 20

  rescans=$(grep -c 'requires a full rescan' "$log" || true)
  reruns=$(( $(grep -c 'Application A is built!' "$log" || true) - builds_before ))
  [ "$reruns" -gt 0 ] && hits=$((hits + 1))
  echo "trial $t: rescan errors=$rescans, app-a rebuilds after burst=$reruns"

  pkill -P "$turbo" || true
  kill "$turbo" 2>/dev/null || true
  wait "$turbo" 2>/dev/null || true
  rm -f "$log"
done

echo "trials with rebuilds: $hits/$trials"
