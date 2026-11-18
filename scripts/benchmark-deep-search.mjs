import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {performance} from 'node:perf_hooks';

const library = process.argv[2] === '--library';
const [base, candidate] = process.argv.slice(library ? 3 : 2).map(file => resolve(file));
assert(base, 'Pass the baseline CLI and optionally the candidate CLI');
const tasks = (count, deadline) => Array.from({length: count}, (_, i) => ({
  id: 't' + i, min_duration: 1, max_duration: 1, release: 0, deadline, resource: 'shared',
}));
const full = {tasks: tasks(24, 24), dependencies: [], max_work: 100000000};
// Loose start-to-start lags exercise the dependency cap while leaving resource ordering to search.
for (let i = 0; i < 24 && full.dependencies.length < 64; i++) {
  for (let j = i + 1; j < 24 && full.dependencies.length < 64; j++) {
    full.dependencies.push({before: 't' + i, after: 't' + j, kind: 'SS', min_lag: -24, max_lag: 24});
  }
}
const ordinary = JSON.parse(readFileSync(new URL('../examples/maintenance-plan.json', import.meta.url)));
const tight = {tasks: tasks(6, 5), max_nodes: 10000, max_work: 100000000};
const rss = 'data:text/javascript,' + encodeURIComponent(
  "process.on('exit', () => console.error(process.resourceUsage().maxRSS))",
);

if (library) {
  assert(candidate, 'Pass both compiled deep-search library drivers');
  const samples = {baseline: [], candidate: []};
  const variants = [['baseline', base], ['candidate', candidate]];
  for (let pair = 0; pair < 4; pair++) {
    for (const [label, driver] of (pair % 2 ? variants.toReversed() : variants)) {
      const proc = spawnSync(process.execPath, ['--import', rss, driver], {encoding: 'utf8', timeout: 60000});
      assert.ifError(proc.error);
      assert.equal(proc.status, 0, proc.stderr);
      const timesMs = proc.stdout.trim().split(/\r?\n/).map(Number);
      assert.equal(timesMs.length, 9);
      assert(timesMs.every(ms => Number.isFinite(ms) && ms > 0));
      const peakRssKiB = Number(proc.stderr.trim());
      assert(Number.isInteger(peakRssKiB) && peakRssKiB > 0);
      samples[label].push({timesMs, peakRssKiB});
    }
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(),
    callsPerSample: 16, warmupsPerProcess: 3, samples}, null, 2));
} else {
  benchmarkCli();
}

function run(cli, request, count, flags = []) {
  const input = JSON.stringify(Array(count).fill(request));
  const start = performance.now();
  const proc = spawnSync(process.execPath, [...flags, '--import', rss, cli, '--plan-batch', '-'], {
    input, encoding: 'utf8', timeout: 60000,
  });
  const ms = performance.now() - start;
  assert.ifError(proc.error);
  assert.equal(proc.status, 0, proc.stderr);
  const peakRssKiB = Number(proc.stderr.trim());
  assert(peakRssKiB > 0 && Number.isInteger(peakRssKiB));
  const results = JSON.parse(proc.stdout);
  assert.equal(results.length, count);
  const result = results[0];
  for (const item of results) assert.deepEqual(item, result);
  return {ms, peakRssKiB, result};
}

function benchmarkCli() {
  const complete = run(base, full, 1).result;
  assert.equal(complete.status, 'planned');
  const {nodes, charged_work} = complete.stats;
  const cases = [
    ['maintenance', ordinary, 64, 'planned'],
    ['max-root', {...full, tasks: full.tasks.map(task => ({...task, resource: task.id}))}, 64, 'planned'],
    ['max-model', full, 16, 'planned'],
    ['tight-impossible', tight, 32, 'unschedulable'],
    ['exact-budgets', {...full, max_nodes: nodes, max_work: charged_work}, 8, 'planned'],
    ['node-limit', {...full, max_nodes: nodes - 1}, 8, 'error'],
    ['work-limit', {...full, max_work: charged_work - 1}, 8, 'error'],
  ];
  const rows = [];
  for (const [name, request, count, status] of cases) {
    const expected = run(base, request, 1).result;
    assert.equal(expected.status, status, JSON.stringify(expected));
    if (status === 'error') {
      assert.equal(expected.code, 'limit_exceeded');
      assert.match(expected.message, name === 'node-limit' ? /node budget/ : /work budget/);
    }
    if (name === 'exact-budgets') assert.deepEqual(expected, complete);
    if (process.env.MOONSTN_CPU_DIR && ['max-model', 'tight-impossible'].includes(name)) {
      const flags = ['--cpu-prof', '--cpu-prof-interval=100', '--cpu-prof-name=' + name + '.cpuprofile',
        '--cpu-prof-dir=' + resolve(process.env.MOONSTN_CPU_DIR)];
      assert.deepEqual(run(base, request, 64, flags).result, expected);
    }
    const variants = candidate ? [['baseline', base], ['candidate', candidate]] : [['baseline', base]];
    const samples = Object.fromEntries(variants.map(([label]) => [label, []]));
    for (let pair = 0; pair < 11; pair++) {
      for (const [label, cli] of (pair % 2 ? variants.toReversed() : variants)) {
        const {result, ...sample} = run(cli, request, count);
        assert.deepEqual(result, expected, name);
        if (pair >= 2) samples[label].push(sample);
      }
    }
    rows.push({name, requestsPerProcess: count, expected, samples});
  }
  console.log(JSON.stringify({node: process.version, platform: process.platform, arch: process.arch,
    recordedAt: new Date().toISOString(), warmupPairs: 2, samplesPerVariant: 9, rows}, null, 2));
}
