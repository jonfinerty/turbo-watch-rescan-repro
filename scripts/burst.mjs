// Writes, then deletes, 100,000 small files in the gitignored apps/app-a/.cache/,
// using 8 worker threads, like a bundler or package manager writing its cache.
import { mkdirSync, rmSync, writeFileSync } from "node:fs";
import { Worker, isMainThread, workerData } from "node:worker_threads";

const WORKERS = 8;
const DIRS_PER_WORKER = 8;
const FILES_PER_DIR = 1563;
const root = new URL("../apps/app-a/.cache/", import.meta.url).pathname;

if (isMainThread) {
  rmSync(root, { recursive: true, force: true });
  await Promise.all(
    Array.from({ length: WORKERS }, (_, worker) =>
      new Promise((resolve, reject) =>
        new Worker(new URL(import.meta.url), { workerData: worker })
          .on("exit", resolve)
          .on("error", reject),
      ),
    ),
  );
  rmSync(root, { recursive: true, force: true });
} else {
  for (let d = 0; d < DIRS_PER_WORKER; d++) {
    const dir = `${root}w${workerData}-d${d}`;
    mkdirSync(dir, { recursive: true });
    for (let f = 0; f < FILES_PER_DIR; f++) writeFileSync(`${dir}/f${f}`, "x");
  }
}
