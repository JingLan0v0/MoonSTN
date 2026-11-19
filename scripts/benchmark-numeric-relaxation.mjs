import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {basename, resolve} from 'node:path';

const [mode, ...args] = process.argv.slice(2);
const drivers = args.map(file => resolve(file));
assert(['library', 'cli', 'profile'].includes(mode), 'Use library, cli or profile');
assert(drivers.length === (mode === 'profile' ? 1 : 2), 'Pass the baseline and candidate, or one profile input');

const shapes = ['positive', 'signed-chain', 'late-cycle'];
const budgets = ['exact', 'exhausted'];
const median = xs => xs.toSorted((a, b) => a - b)[Math.floor(xs.length / 2)];
const probe = 'data:text/javascript,' + encodeURIComponent(
  'process.once("exit", () => console.error(JSON.stringify({peakRssKiB: process.resourceUsage().maxRSS, ...globalThis.relaxPhases})))',
);
function invoke(driver, argv, input) {
  const start = performance.now();
  const r = spawnSync(process.execPath, ['--import', probe, driver, ...argv], {
    input, encoding: 'utf8', timeout: 20000, maxBuffer: 4 * 1024 * 1024,
  });
  const elapsedMs = performance.now() - start;
  assert.ifError(r.error);
  assert.equal(r.status, 0, r.stderr);
  const measured = JSON.parse(r.stderr.trim());
  assert(measured.peakRssKiB > 0);
  return {stdout: r.stdout, elapsedMs, ...measured};
}
function librarySample(driver, shape, budget) {
  const {stdout, elapsedMs, ...sample} = invoke(driver, [shape, budget]);
  const samplesMs = stdout.trim().split(/\r?\n/).map(Number);
  assert.equal(samplesMs.length, 9);
  assert(samplesMs.every(ms => ms > 0 && Number.isFinite(ms)));
  return {samplesMs, medianMs: median(samplesMs), ...sample};
}
function markPhases(driver) {
  const source = readFileSync(driver, 'utf8').replaceAll('\r\n', '\n');
  const relax = '_M0FP210JingLan0v03stn5relax';
  assert(source.includes('function ' + relax + '('), 'Missing baseline relax symbol');
  const start = source.indexOf('function _M0FP210JingLan0v03stn14solve__indexed(');
  const end = source.indexOf('\nfunction ', start + 1);
  assert(start >= 0 && end > start, 'Missing baseline solver symbol');
  const begin = '  if (_changed !== -1) {';
  const finish = '\n  }\n  _M0FP210JingLan0v03stn9normalize(_values);';
  const body = source.slice(start, end);
  assert(body.includes(begin) && body.includes(finish), 'Missing 0.2.13 certificate markers');
  const marked = body
    .replace(begin, begin + '\n    const certStart = performance.now();\n    try {')
    .replace(finish, '\n    } finally { relaxPhases.certificateMs += performance.now() - certStart; relaxPhases.certificateCalls++; }' + finish);
  return 'globalThis.relaxPhases = {relaxMs: 0, relaxCalls: 0, certificateMs: 0, certificateCalls: 0};\n' +
    'const originalRelax = ' + relax + ';\n' + relax + ' = (...args) => {\n' +
    '  const start = performance.now();\n  try { return originalRelax(...args); }\n' +
    '  finally { relaxPhases.relaxMs += performance.now() - start; relaxPhases.relaxCalls++; }\n};\n' +
    source.slice(0, start) + marked + source.slice(end);
}
function libraryRows() {
  const tmp = mode === 'profile' ? mkdtempSync(resolve('_build', 'relax-profile-')) : null;
  const profiled = tmp ? resolve(tmp, 'probe.js') : null;
  try {
    if (tmp) writeFileSync(profiled, markPhases(drivers[0]));
    return shapes.flatMap(shape => budgets.map(budget => {
      const measurements = tmp ? [[]] : [[], []];
      for (let round = 0; round < (tmp ? 5 : 2); round++) {
        for (const index of tmp ? [0] : round ? [1, 0] : [0, 1]) {
          const sample = librarySample(profiled ?? drivers[index], shape, budget);
          if (tmp) {
            assert.equal(sample.relaxCalls, 769);
            assert.equal(sample.certificateCalls, shape === 'late-cycle' ? 769 : 0);
          }
          measurements[index].push(sample);
        }
      }
      return {shape, budget, measurements};
    }));
  } finally {
    if (tmp) {
      rmSync(profiled, {force: true});
      rmdirSync(tmp);
    }
  }
}
const names = Array.from({length: 64}, (_, i) => 'v' + i);
function request(shape, budget) {
  const chain = Array.from({length: 63}, (_, i) => {
    const source = 62 - i;
    return {id: 'chain' + source, from: names[source], to: names[source + 1], upper: shape === 'positive' ? 1 : -1};
  });
  const constraints = [...chain];
  for (const [i, from] of names.entries()) {
    for (let jump = 2; jump <= 8; jump++) {
      constraints.push({id: 'decoy' + constraints.length, from, to: names[(i + jump) % 64], upper: 128});
    }
  }
  constraints.push({id: 'tail', from: 'v63', to: 'v0', upper: shape === 'late-cycle' ? 62 : 128});
  const exact = {'positive': 2 * 512 + 64 ** 3, 'signed-chain': 65 * 512 + 64 ** 3, 'late-cycle': 64 * 512 + 128};
  return {timepoints: names, constraints, queries: [{from: 'v0', to: 'v63'}],
    max_steps: exact[shape] - (budget === 'exhausted' ? 1 : 0)};
}
function checkResult(model, shape, budget, actual) {
  if (budget === 'exhausted') {
    assert.equal(actual.status, 'error');
    assert.equal(actual.code, 'limit_exceeded');
  } else if (shape === 'late-cycle') {
    assert.equal(actual.status, 'inconsistent');
    assert.equal(actual.cycle.length, 64);
    const rules = new Map(model.constraints.map(rule => [rule.id, rule]));
    for (const [i, edge] of actual.cycle.entries()) {
      const rule = rules.get(edge.id);
      assert.deepEqual(edge, {id: rule.id, from: rule.from, to: rule.to, bound: rule.upper, side: 'upper'});
      assert.equal(edge.to, actual.cycle[(i + 1) % 64].from);
    }
    assert.equal(actual.cycle.reduce((total, edge) => total + edge.bound, 0), -1);
  } else {
    assert.equal(actual.status, 'feasible');
    assert.equal(actual.assignment.v0, 0);
    assert.equal(actual.bounds[0].upper, shape === 'positive' ? 63 : -63);
    for (const edge of model.constraints) {
      assert(actual.assignment[edge.to] - actual.assignment[edge.from] <= edge.upper);
    }
  }
}
function cliRows() {
  const run = (driver, batch) => invoke(driver, ['--batch', '-'], JSON.stringify(batch));
  const rows = shapes.flatMap(shape => budgets.map(budget => {
    const model = request(shape, budget);
    const batch = Array(12).fill(model);
    const reference = run(drivers[0], batch).stdout;
    const results = JSON.parse(reference);
    assert.equal(results.length, batch.length);
    for (const actual of results) checkResult(model, shape, budget, actual);
    const measurements = [[], []];
    for (let round = 0; round < 11; round++) {
      for (const index of round % 2 ? [1, 0] : [0, 1]) {
        const {stdout, ...sample} = run(drivers[index], batch);
        assert.equal(stdout, reference, shape + '/' + budget);
        if (round >= 2) measurements[index].push(sample);
      }
    }
    return {shape, budget, count: batch.length, sha256: createHash('sha256').update(reference).digest('hex'), measurements};
  }));
  const late = request('late-cycle', 'exact');
  const early = {...late, max_steps: 64 * 512 - 1};
  const entry = {...late, max_steps: 64 * 512 + 64};
  const feasible = request('signed-chain', 'exact');
  const mixed = [late, early, entry, request('late-cycle', 'exhausted'), feasible, late];
  const expected = run(drivers[0], mixed).stdout;
  assert.equal(run(drivers[1], mixed).stdout, expected);
  const decoded = JSON.parse(expected);
  assert.deepEqual(decoded.map(x => x.status), ['inconsistent','error','error','error','feasible','inconsistent']);
  assert(decoded.slice(1, 4).every(x => x.code === 'limit_exceeded'));
  assert.deepEqual(decoded[0], decoded.at(-1));
  return {rows, mixedItems: mixed.length, mixedSha256: createHash('sha256').update(expected).digest('hex')};
}
const result = mode === 'cli' ? cliRows() : {rows: libraryRows()};
console.log(JSON.stringify({mode, node: process.version, recordedAt: new Date().toISOString(),
  drivers: drivers.map(file => basename(file)), callsPerLibrarySample: 64, ...result}, null, 2));
