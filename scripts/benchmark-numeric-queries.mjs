import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {performance} from 'node:perf_hooks';

const [baseline, candidate] = process.argv.slice(2).map(file => resolve(file));
assert(baseline, 'Pass the baseline CLI and optionally the candidate CLI');
const names = Array.from({length: 64}, (_, i) => 'point-' + i);
const chain = names.slice(1).map((to, i) => ({id: 'e' + i, from: names[i], to, upper: 1}));
const dense = names.flatMap((from, i) => Array.from({length: 8}, (_, j) => ({
  id: 'e' + i + '-' + j, from, to: names[(i + j + 1) % 64], upper: 1,
})));
const pairs = Array.from({length: 256}, (_, i) => [(37 * i) % 64, (13 * i + Math.floor(i / 7)) % 64]);
const queries = pairs.map(([a, b]) => ({from: names[a], to: names[b]}));
const sparse = {timepoints: names, constraints: [], queries, max_steps: 64 ** 3};
const impossible = {...sparse, constraints: [{id: 'cycle', from: names[63], to: names[63], upper: -1}], max_steps: 129};
const cases = [
  ['ordinary', 32, {timepoints: names.slice(0, 4), constraints: chain.slice(0, 3),
    queries: [{from: names[0], to: names[3]}]}, 'feasible'],
  ['sparse', 48, sparse, 'feasible'],
  ['chain', 32, {...sparse, constraints: chain, max_steps: 64 ** 3 + 2 * chain.length}, 'feasible'],
  ['dense', 16, {...sparse, constraints: dense, max_steps: 64 ** 3 + 2 * dense.length}, 'feasible'],
  ['budget-limit', 32, {...sparse, max_steps: sparse.max_steps - 1}, 'error'],
  ['negative-cycle', 32, impossible, 'inconsistent'],
];
if (process.env.MOONSTN_BENCH_CLOSURE_BUDGET === '1') {
  cases.push(
    ['chain-closure-budget', 32, {...sparse, constraints: chain, max_steps: 64 ** 3 + 2 * chain.length - 1}, 'error'],
    ['dense-closure-budget', 16, {...sparse, constraints: dense, max_steps: 64 ** 3 + 2 * dense.length - 1}, 'error'],
    ['dense-init-budget', 16, {...sparse, constraints: dense, max_steps: dense.length}, 'error'],
  );
}
if (process.env.MOONSTN_BENCH_WIDE === '1') {
  const branches = names.slice(1).map((to, i) => ({
    id: 'branch-' + i, from: names[Math.floor(i / 2)], to, upper: -1,
  }));
  const groups = chain.filter((_, i) => (i + 1) % 16 !== 0);
  cases.push(
    ['signed-branches', 32, {...sparse, constraints: branches, max_steps: 64 ** 3 + 3 * branches.length}, 'feasible'],
    ['chain-groups', 32, {...sparse, constraints: groups, max_steps: 64 ** 3 + 2 * groups.length}, 'feasible'],
  );
}
if (process.env.MOONSTN_BENCH_DENSITY === '1') {
  for (const size of [31, 32]) {
    const timepoints = names.slice(0, size);
    const constraints = timepoints.flatMap((from, i) => Array.from({length: 4}, (_, j) => ({
      id: 'e' + i + '-' + j, from, to: timepoints[(i + j + 1) % size], upper: 1,
    })));
    cases.push(['ring-' + size, 32, {timepoints, constraints, queries: queries.filter(
      ({from, to}) => timepoints.includes(from) && timepoints.includes(to),
    )}, 'feasible']);
  }
  const repeated = dense.map(edge => ({...edge, from: names[0], to: names[63]}));
  const grouped = dense.map(({id, from, upper}, i) => {
    const source = Math.floor(i / 8);
    const group = Math.floor(source / 16) * 16;
    return {id, from, upper, to: names[group + (source % 16 + i % 8 + 1) % 16]};
  });
  cases.push(
    ['parallel-only', 16, {...sparse, constraints: repeated, max_steps: 2000000}, 'feasible'],
    ['four-groups', 16, {...sparse, constraints: grouped, max_steps: 2000000}, 'feasible'],
  );
}
const wideningOnly = process.env.MOONSTN_BENCH_WIDENING_ONLY === '1';
if (wideningOnly || process.env.MOONSTN_BENCH_WIDENING === '1') {
  const potential = i => 23 * i * i;
  const varied = dense.map((edge, index) => {
    const source = Math.floor(index / 8);
    const target = (source + index % 8 + 1) % 64;
    return {...edge, upper: 100000 + potential(target) - potential(source)};
  });
  for (const [style, constraints] of [['repeated', dense], ['varied', varied]]) {
    for (const count of [0, 4, 256]) {
      cases.push([`widen-${style}-${count}`, 12, {
        timepoints: names, constraints, queries: queries.slice(0, count),
        max_steps: 64 ** 3 + 2 * constraints.length,
      }, 'feasible']);
    }
  }
}
const probe = 'data:text/javascript,' + encodeURIComponent(
  'process.once("exit", () => console.error(JSON.stringify({peakRssKiB: process.resourceUsage().maxRSS, ...globalThis.queryPhases})));',
);
function expectedBounds(shape, from, to) {
  if (from === to) return {lower: 0, upper: 0};
  if (shape === 'dense') return {
    lower: -Math.ceil(((from - to + 64) % 64) / 8),
    upper: Math.ceil(((to - from + 64) % 64) / 8),
  };
  if (shape === 'chain') return {
    lower: to < from ? to - from : null,
    upper: to > from ? to - from : null,
  };
  return {lower: null, upper: null};
}
function invoke(cli, batch) {
  const input = JSON.stringify(batch);
  const start = performance.now();
  const r = spawnSync(process.execPath, ['--import', probe, cli, '--batch', '-'], {
    input, encoding: 'utf8', timeout: 15000, maxBuffer: 4 * 1024 * 1024,
  });
  const elapsedMs = performance.now() - start;
  assert.ifError(r.error);
  assert.equal(r.status, 0, r.stderr);
  return {output: r.stdout, sample: {elapsedMs, ...JSON.parse(r.stderr)}};
}
function profile(source) {
  const replace = (marker, insertion) => {
    assert(source.includes(marker), 'Missing compiler marker ' + marker);
    source = source.replace(marker, insertion + '\n' + marker);
  };
  replace('    const queries = [];', '    const queriesStarted = performance.now();');
  replace('    const _bind$4 = _M0FP210JingLan0v03stn13solve_2einner(net, steps);',
    '    queryPhases.queryValidationMs += performance.now() - queriesStarted;');
  replace('      const assignment = _M0MPB3Map3MapGsRPB4JsonE',
    '      const resultStarted = performance.now();');
  replace('      return new _M0DTPC16result6ResultGRPB4JsonRP210JingLan0v03stn8StnErrorE2Ok(new _M0DTPB4Json6Object(_p$3));',
    '      queryPhases.feasibleResultMs += performance.now() - resultStarted;');
  replace('  let _tmp$3 = 0;\n  while (true) {\n    const k = _tmp$3;',
    '  const closureStarted = performance.now();');
  replace('  return new _M0DTPC16result6ResultGRP210JingLan0v03stn7OutcomeRP210JingLan0v03stn8StnErrorE2Ok(new _M0DTP210JingLan0v03stn7Outcome8Feasible',
    '  queryPhases.closureMs += performance.now() - closureStarted;');
  return 'globalThis.queryPhases = {lookupCalls:0, lookupMs:0, queryValidationMs:0, closureMs:0, feasibleResultMs:0};\n' +
    'const lookup = _M0FP210JingLan0v03stn10find__name;\n' +
    '_M0FP210JingLan0v03stn10find__name = (...args) => { const start = performance.now();\n' +
    'try {return lookup(...args)} finally {queryPhases.lookupCalls++; queryPhases.lookupMs += performance.now()-start} };\n' + source;
}
function profileWidening(source) {
  const start = source.indexOf('function _M0FP210JingLan0v03stn17narrow__distances(');
  const end = source.indexOf('\nfunction ', start + 1);
  assert(start >= 0 && end > start, 'Missing 0.2.12 narrow closure symbol');
  const body = source.slice(start, end);
  const materialize = '  let _tmp$4;\n  if (n <= 0)';
  const returned = '  return new _M0DTPC16result6ResultGORPB5ArrayGRPB5ArrayGOlEERP210JingLan0v03stn8StnErrorE2Ok(new';
  assert(body.includes(materialize) && body.includes(returned), 'Missing 0.2.12 widening markers');
  const marked = body
    .replace(materialize, '  const widenStart = performance.now();\n' + materialize)
    .replace(returned, '  queryPhases.widenMs += performance.now() - widenStart;\n  queryPhases.widenCalls++;\n' + returned);
  return 'globalThis.queryPhases = {widenMs: 0, widenCalls: 0};\n' + source.slice(0, start) + marked + source.slice(end);
}
const wideningProfile = process.env.MOONSTN_PROFILE_WIDENING === '1';
const profiling = wideningProfile || process.env.MOONSTN_PROFILE_QUERIES === '1';
assert(!profiling || !candidate, 'Phase markers require a single matching baseline CLI');
const tmp = profiling ? mkdtempSync(resolve('_build', 'query-profile-')) : null;
const file = tmp ? resolve(tmp, 'profile.js') : baseline;

try {
  if (tmp) writeFileSync(file, (wideningProfile ? profileWidening : profile)(readFileSync(baseline, 'utf8').replaceAll('\r\n', '\n')));
  const rows = [];
  const runs = wideningOnly ? 7 : 11;
  for (const [name, count, request, status] of cases) {
    if (wideningOnly && !name.startsWith('widen-')) continue;
    const batch = Array(count).fill(request);
    const expected = invoke(baseline, batch).output;
    const results = JSON.parse(expected);
    assert.equal(results.length, count);
    for (const result of results) {
      assert.equal(result.status, status, name);
      if (status === 'error') assert.equal(result.code, 'limit_exceeded');
      if (status === 'inconsistent') assert.deepEqual(result.cycle, [
        {id: 'cycle', from: names[63], to: names[63], bound: -1, side: 'upper'},
      ]);
      if (name.startsWith('widen-')) {
        const scale = name.startsWith('widen-varied-') ? 100000 : 1;
        assert.deepEqual(result.bounds, pairs.slice(0, request.queries.length).map(([a, b]) => {
          const delta = scale === 1 ? 0 : 23 * (b * b - a * a);
          return {
            from: names[a], to: names[b],
            lower: delta - scale * Math.ceil(((a - b + 64) % 64) / 8),
            upper: delta + scale * Math.ceil(((b - a + 64) % 64) / 8),
          };
        }));
      }
      if (['sparse', 'chain', 'dense'].includes(name)) {
        assert.deepEqual(result.bounds, pairs.map(([a, b]) => ({
          from: names[a], to: names[b],
          ...expectedBounds(name, a, b),
        })));
      }
    }
    const variants = candidate ? [['baseline', baseline], ['candidate', candidate]] : [['baseline', file]];
    const samples = Object.fromEntries(variants.map(([label]) => [label, []]));
    for (let pair = 0; pair < runs; pair++) {
      for (const [label, cli] of (pair % 2 ? variants.toReversed() : variants)) {
        const {output, sample} = invoke(cli, batch);
        assert.equal(output, expected, name);
        if (wideningProfile && name.startsWith('widen-')) assert.equal(sample.widenCalls, count);
        if (pair >= 2) samples[label].push(sample);
      }
    }
    rows.push({name, count, outputBytes: Buffer.byteLength(expected),
      outputSha256: createHash('sha256').update(expected).digest('hex'), samples});
  }
  const unknown = {...impossible, max_steps: 1, queries: [{from: 'missing-first', to: 'missing-second'}]};
  const checks = [sparse, unknown, {...sparse, queries: [...queries, queries[0]]},
    {...unknown, max_steps: 0}, {...impossible, max_steps: 128}, impossible, sparse];
  const expected = invoke(baseline, checks).output;
  const results = JSON.parse(expected);
  assert.deepEqual(results.map(r => r.status), ['feasible', 'error', 'error', 'error', 'error', 'inconsistent', 'feasible']);
  assert.equal(results[1].message, 'unknown timepoint: missing-first');
  assert.equal(results[2].message, 'at most 256 queries');
  assert.match(results[3].message, /^max_steps must be an integer/);
  assert.equal(results[4].code, 'limit_exceeded');
  assert.deepEqual(results[0], results.at(-1));
  if (candidate) assert.equal(invoke(candidate, checks).output, expected);
  console.log(JSON.stringify({node: process.version, profiling, recordedAt: new Date().toISOString(),
    warmupPairs: 2, measuredPairs: runs - 2, checkedBatchItems: checks.length, rows}, null, 2));
} finally {
  if (tmp) {
    rmSync(file, {force: true});
    rmdirSync(tmp);
  }
}
