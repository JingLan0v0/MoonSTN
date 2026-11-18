import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {performance} from 'node:perf_hooks';
import path from 'node:path';

const current = path.resolve(import.meta.dirname, '../_build/js/release/build/cmd/main/main.js');
const baseline = process.argv[2] && path.resolve(process.argv[2]);
const warmups = 2;
const samples = 9;
const scenarios = [
  {name: 'independent', groupSize: 0, deadline: 24, count: 64, status: 'planned'},
  {name: 'four-resources', groupSize: 6, deadline: 24, count: 8, status: 'planned'},
  {name: 'one-resource', groupSize: 24, deadline: 24, count: 2, status: 'planned'},
  {name: 'one-resource-overload', groupSize: 24, deadline: 12, count: 2, status: 'error'},
];

function invoke(cli, input) {
  const start = performance.now();
  const result = spawnSync(process.execPath, [cli, '--plan-batch', '-'], {
    input, encoding: 'utf8', timeout: 30000,
  });
  const ms = performance.now() - start;
  assert.equal(result.error, undefined);
  assert.equal(result.status, 0, result.stderr);
  return {ms, results: JSON.parse(result.stdout)};
}

function median(times) {
  return times.toSorted((a, b) => a - b)[Math.floor(times.length / 2)];
}

const rows = [];
for (const {name, groupSize, deadline, count, status} of scenarios) {
  const tasks = Array.from({length: 24}, (_, i) => ({
    id: `t${i}`, min_duration: 1, max_duration: 1, release: 0, deadline,
    resource: groupSize === 0 ? null : `r${Math.floor(i / groupSize)}`,
  }));
  const request = {tasks, max_work: 100000000};
  const input = JSON.stringify(Array(count).fill(request));
  const expected = invoke(baseline ?? current, input).results;
  assert.equal(expected.length, count);
  for (const result of expected) {
    assert.equal(result.status, status);
    if (status === 'error') assert.equal(result.code, 'limit_exceeded');
  }
  const times = {baseline: [], current: []};
  for (let i = 0; i < warmups + samples; i++) {
    const order = i % 2 === 0 ? ['baseline', 'current'] : ['current', 'baseline'];
    for (const label of order) {
      const cli = label === 'baseline' ? baseline : current;
      if (!cli) continue;
      const measured = invoke(cli, input);
      assert.deepEqual(measured.results, expected, name);
      if (i >= warmups) times[label].push(measured.ms);
    }
  }
  rows.push({
    name, requestsPerSample: count, result: expected[0].stats ?? expected[0].code,
    currentMedianMs: median(times.current),
    ...(baseline ? {baselineMedianMs: median(times.baseline)} : {}),
  });
}
console.log(JSON.stringify({
  recordedAt: new Date().toISOString(), node: process.version, samples, warmups,
  includesProcessStartup: true, rows,
}, null, 2));
