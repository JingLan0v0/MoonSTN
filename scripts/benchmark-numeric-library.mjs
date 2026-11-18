import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {basename, resolve} from 'node:path';

const drivers = process.argv.slice(2).map(file => resolve(file));
assert(drivers.length === 2 || drivers.length === 3, 'Pass two or three compiled numeric benchmark drivers');
const peakRss = 'data:text/javascript,' + encodeURIComponent(
  "process.once('exit', () => console.error(process.resourceUsage().maxRSS))",
);
const median = xs => xs.toSorted((a, b) => a - b)[Math.floor(xs.length / 2)];
const rows = [];
for (const shape of ['disconnected', 'chain', 'connected']) {
  for (const budget of ['default', 'exhausted']) {
    const measurements = drivers.map(() => []);
    // Each driver runs once in each position.
    for (let round = 0; round < drivers.length; round++) {
      for (let offset = 0; offset < drivers.length; offset++) {
        const index = (round + offset) % drivers.length;
        const run = spawnSync(process.execPath, ['--import', peakRss, drivers[index], shape, budget], {
          encoding: 'utf8', timeout: 120000,
        });
        assert.equal(run.error, undefined);
        assert.equal(run.status, 0, run.stderr);
        const samplesMs = run.stdout.trim().split(/\r?\n/).map(Number);
        assert.equal(samplesMs.length, 9);
        assert(samplesMs.every(ms => Number.isFinite(ms) && ms > 0));
        const peakRssKiB = Number(run.stderr.trim());
        assert(Number.isInteger(peakRssKiB) && peakRssKiB > 0);
        measurements[index].push({samplesMs, medianMs: median(samplesMs), peakRssKiB});
      }
    }
    rows.push({shape, budget, measurements});
  }
}
console.log(JSON.stringify({
  recordedAt: new Date().toISOString(), node: process.version, drivers: drivers.map(file => basename(file)),
  callsPerSample: {disconnected: 2048, chain: 128, connected: 128},
  warmups: 3, samplesPerProcess: 9, rows,
}, null, 2));
