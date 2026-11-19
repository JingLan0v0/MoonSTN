import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {basename, resolve} from 'node:path';

const [baseline, candidate] = process.argv.slice(2).map(file => resolve(file));
assert(baseline, 'Pass the baseline CLI and optionally the candidate CLI');
const profiling = process.env.MOONSTN_PROFILE_NUMERIC_RESULTS === '1';
const keys = ['10', '2', '01', '__proto__', 'constructor', 'toString'];
const names = keys.concat(Array.from({length: 58}, (_, i) => 'p' + i));
const longNames = names.map((name, i) => i < keys.length ? name : name.padEnd(64, '-'));
const pairs = [[0, 0], [0, 2], [2, 1], [3, 0], ...Array.from({length: 252}, (_, i) =>
  [13 * i % 64, (37 * i + Math.floor(i / 5)) % 64],
)];

function feasible(timepoints, count) {
  return {
    timepoints,
    constraints: [
      {id: 'forward', from: timepoints[0], to: timepoints[1], upper: 5},
      {id: 'signed', from: timepoints[1], to: timepoints[2], upper: -3},
    ],
    queries: pairs.slice(0, count).map(([a, b]) => ({from: timepoints[a], to: timepoints[b]})),
  };
}
const ring = {
  timepoints: names,
  constraints: names.slice(0, -1).map((from, i) => ({id: 'c' + i, from, to: names[i + 1], upper: 0})),
  max_steps: 64 * 64 + 128,
};
ring.constraints.push({id: 'last', from: names[0], to: names[63], lower: 1});
const noBudget = {...feasible(names, 0), max_steps: 1};
const unknown = {...feasible(names, 0), queries: [{from: 'line\n"\u2603', to: names[1]}]};
const cases = [
  {name: 'ordinary', requests: 64, inputs: [feasible(names.slice(0, 4), 4)]},
  {name: 'assignment-only', requests: 64, inputs: [feasible(names, 0)]},
  {name: 'four-queries', requests: 64, inputs: [feasible(names, 4)]},
  {name: '256-queries', requests: 64, inputs: [feasible(names, 256)]},
  {name: 'long-names', requests: 24, inputs: [feasible(longNames, 256)]},
  {name: 'cycle-64', requests: 64, inputs: [ring]},
  {name: 'mixed', requests: 64, inputs: [feasible(names, 4), ring, noBudget, unknown]},
];
const probe = 'data:text/javascript,' + encodeURIComponent(
  'process.once("exit", () => console.error(JSON.stringify({peakRssKiB: process.resourceUsage().maxRSS, ...globalThis.numericResultPhases})));',
);
function invoke(cli, input) {
  const start = performance.now();
  const p = spawnSync(process.execPath, ['--import', probe, cli, '--batch', '-'], {
    input, encoding: 'utf8', timeout: 15000, maxBuffer: 8 * 1024 * 1024,
  });
  const elapsedMs = performance.now() - start;
  assert.ifError(p.error);
  assert.equal(p.status, 0, p.stderr);
  const phases = JSON.parse(p.stderr);
  assert(Number.isInteger(phases.peakRssKiB) && phases.peakRssKiB > 0);
  return {output: p.stdout, sample: {elapsedMs, ...phases}};
}
function instrument(source) {
  source = source.replaceAll('\r\n', '\n');
  const start = source.indexOf('function _M0FP210JingLan0v03stn7analyze(');
  const end = source.indexOf('\nfunction ', start + 1);
  assert(start >= 0 && end > start, 'Missing numeric analyze symbol');
  let body = source.slice(start, end);
  function before(marker, statement) {
    assert(body.includes(marker), 'Missing numeric result marker ' + marker);
    body = body.replace(marker, statement + '\n' + marker);
  }
  before('      const assignment =', '      const assignmentStart = performance.now();');
  before('      const _p = new Array(queries.length);',
    '      const boundsStart = performance.now();\n      numericResultPhases.assignmentMs += boundsStart - assignmentStart;');
  before('      const ranges = _p;', '      numericResultPhases.boundsMs += performance.now() - boundsStart;');
  before('      const _cycle = _Inconsistent._0;', '      const cycleStart = performance.now();');
  before('      const edges = _p;', '      numericResultPhases.cycleMs += performance.now() - cycleStart;');
  const numericWriter = source.match(/^function (\w+numeric__output)\(/m);
  const symbols = {
    errorMs: '_M0FP210JingLan0v03stn11error__json',
    stringifyMs: numericWriter?.[1] ?? '_M0MPC14json4Json17stringify_2einner',
  };
  const lines = ['globalThis.numericResultPhases = {assignmentMs:0,boundsMs:0,cycleMs:0,errorMs:0,stringifyMs:0};'];
  for (const [key, fn] of Object.entries(symbols)) {
    assert(source.includes('function ' + fn + '('), 'Missing compiler function ' + fn);
    lines.push('const saved_' + key + ' = ' + fn + '; ' + fn + ' = (...args) => {',
      'const start = performance.now(); try { return saved_' + key + '(...args); }',
      'finally { numericResultPhases.' + key + ' += performance.now() - start; } };');
  }
  return lines.join('\n') + '\n' + source.slice(0, start) + body + source.slice(end);
}
const exactUpper = new Map([['0:1', 5], ['0:2', 2], ['1:2', -3]]);
function checkResult(actual, request) {
  if (request === noBudget || request === unknown) {
    assert.equal(actual.status, 'error');
    assert.equal(actual.code, request === noBudget ? 'limit_exceeded' : 'invalid_input');
    if (request === unknown) assert.equal(actual.message, 'unknown timepoint: ' + unknown.queries[0].from);
    return;
  }
  if (request === ring) {
    assert.equal(actual.status, 'inconsistent');
    assert.equal(actual.cycle.length, 64);
    const authentic = ring.constraints.map(({id, from, to, lower, upper}) =>
      lower === undefined ? {id, from, to, bound: upper, side: 'upper'} :
        {id, from: to, to: from, bound: -lower, side: 'lower'});
    for (const [i, edge] of actual.cycle.entries()) {
      assert.deepEqual(edge, authentic.find(rule => rule.id === edge.id));
      assert.equal(edge.to, actual.cycle[(i + 1) % 64].from);
    }
    assert.equal(actual.cycle.reduce((sum, edge) => sum + edge.bound, 0), -1);
    assert.equal(new Set(actual.cycle.map(edge => edge.id)).size, 64);
    return;
  }
  assert.equal(actual.status, 'feasible');
  assert.equal(Object.keys(actual.assignment).length, request.timepoints.length);
  for (const [i, name] of request.timepoints.entries()) assert.equal(actual.assignment[name], i === 2 ? -3 : 0);
  assert.deepEqual(actual.bounds, request.queries.map(({from, to}, i) => {
    const [a, b] = pairs[i];
    const reverse = exactUpper.get(b + ':' + a);
    return {from, to, lower: a === b ? 0 : reverse === undefined ? null : -reverse,
      upper: a === b ? 0 : exactUpper.get(a + ':' + b) ?? null};
  }));
}
const variants = candidate ? [['baseline', baseline], ['candidate', candidate]] : [['baseline', baseline]];
const tmp = profiling ? mkdtempSync(resolve('_build', 'numeric-result-profile-')) : null;
let active = variants;
try {
  if (tmp) {
    active = variants.map(([label, file]) => {
      const target = resolve(tmp, label + '.js');
      writeFileSync(target, instrument(readFileSync(file, 'utf8')));
      return [label, target];
    });
  }
  const rows = [];
  for (const {name, requests, inputs} of cases) {
    const batch = Array.from({length: requests}, (_, i) => inputs[i % inputs.length]);
    const input = JSON.stringify(batch);
    assert(input.length <= 1048576);
    const reference = invoke(baseline, input).output;
    const decoded = JSON.parse(reference);
    assert.equal(decoded.length, batch.length);
    decoded.forEach((item, i) => checkResult(item, batch[i]));
    // Numeric-looking names verify encoded insertion order, including special JS names.
    assert(!decoded.some(r => r.status === 'feasible') ||
      reference.includes('"assignment":{' + batch[0].timepoints.map((p, i) => JSON.stringify(p) + ':' + (i === 2 ? -3 : 0)).join(',') + '}'));
    const samples = Object.fromEntries(variants.map(([label]) => [label, []]));
    for (let pair = 0; pair < 11; pair++) {
      for (const [label, cli] of pair % 2 ? active.toReversed() : active) {
        const {output, sample} = invoke(cli, input);
        assert.equal(output, reference, name + '/' + label);
        if (profiling) assert(sample.stringifyMs > 0);
        if (pair >= 2) samples[label].push(sample);
      }
    }
    rows.push({name, requests, inputBytes: Buffer.byteLength(input), outputBytes: Buffer.byteLength(reference),
      outputSha256: createHash('sha256').update(reference).digest('hex'), samples});
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(),
    drivers: variants.map(([,file]) => basename(file)), profiling, warmupPairs: 2, measuredPairs: 9, rows}, null, 2));
} finally {
  if (tmp) {
    for (const [label] of variants) rmSync(resolve(tmp, label + '.js'), {force: true});
    rmdirSync(tmp);
  }
}
