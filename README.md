# `turbo watch` reruns tasks after a file burst in a gitignored directory (macOS)

This is the `with-shell-commands` example plus two scripts:

- `scripts/burst.mjs` writes, then deletes, 100,000 files in the gitignored `apps/app-a/.cache/`.
- `scripts/repro.sh` runs 8 trials. Each trial starts `turbo watch build`, runs the burst, and counts the full-rescan errors and the `app-a` rebuilds that follow.

```bash
pnpm install
./scripts/repro.sh
```

No tracked file changes, so the expected result is 0 rebuilds in every trial.
