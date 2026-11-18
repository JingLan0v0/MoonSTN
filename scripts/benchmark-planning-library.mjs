import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {resolve} from 'node:path';

assert.equal(process.argv.length, 4, 'Pass the compiled baseline and candidate benchmark drivers');
const labels = ['baseline', 'candidate'];
const cli = Object.fromEntries(labels.map((label, i) => [label, resolve(process.argv[i + 2])]));
const cases = ['maintenance', 'independent', 'distinct-resources', 'first-pair', 'last-pair',
  'four-resources', 'one-resource', 'max-root', 'max-model'];

const rows = cases.map(name => {
  const samples = {baseline: [], candidate: []};
  let expected;
  for (let pair = 0; pair < 3; pair++) {
    for (const label of pair % 2 === 0 ? labels : labels.toReversed()) {
      const result = spawnSync(process.execPath, [cli[label], name], {encoding: 'utf8', timeout: 30000});
      assert.equal(result.error, undefined);
      assert.equal(result.status, 0, result.stderr);
      const batch = result.stdout.trim().split(/\r?\n/).map(line => {
        const [ms, work, checksum] = line.split(',');
        expected ??= [work, checksum];
        assert.deepEqual([work, checksum], expected, name);
        assert(Number(ms) > 0);
        return Number(ms);
      });
      assert.equal(batch.length, 9);
      samples[label].push(batch);
    }
  }
  const medianMs = Object.fromEntries(labels.map(label => {
    const sorted = samples[label].flat().toSorted((a, b) => a - b);
    return [label, sorted[Math.floor(sorted.length / 2)]];
  }));
  return {name, medianMs, samples, work: expected[0], checksum: expected[1]};
});
console.log(JSON.stringify({
  recordedAt: new Date().toISOString(), node: process.version, callsPerSample: 500,
  processPairs: 3, warmupsPerProcess: 3, rows,
}, null, 2));
