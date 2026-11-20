import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {basename, resolve} from 'node:path';

const [baseline, candidate] = process.argv.slice(2).map(file => resolve(file));
assert(baseline, 'Pass the baseline CLI and optionally the candidate CLI');
const preflight = process.env.MOONSTN_BENCH_NUMERIC_PREFLIGHT === '1';
const profilePreflight = process.env.MOONSTN_PROFILE_NUMERIC_PREFLIGHT === '1';
const profileRequests = process.env.MOONSTN_PROFILE_NUMERIC_REQUESTS === '1';
const profileModel = process.env.MOONSTN_PROFILE_NUMERIC_MODEL === '1';
const profileConstraints = process.env.MOONSTN_PROFILE_NUMERIC_CONSTRAINTS === '1';
const constraintFields = profileConstraints || process.env.MOONSTN_BENCH_NUMERIC_CONSTRAINTS === '1';
const model = profileModel || process.env.MOONSTN_BENCH_NUMERIC_MODEL === '1';
const requests = profilePreflight || preflight || profileRequests || process.env.MOONSTN_BENCH_NUMERIC_REQUESTS === '1';
const profiling = profileConstraints || profileModel || profilePreflight || profileRequests || process.env.MOONSTN_PROFILE_NUMERIC_RESULTS === '1';
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
const manyConstraints = feasible(names, 4);
manyConstraints.constraints.push(...Array.from({length: 510}, (_, i) => {
  const source = 3 + Math.floor(i / 9);
  return {id:'noise' + i, from:names[source], to:names[3 + (source - 3 + i % 9 + 1) % 61], upper:1000};
}));
const unknown = {...feasible(names, 0), queries: [{from: 'line\n"\u2603', to: names[1]}]};
const twoSided = {...manyConstraints, constraints: manyConstraints.constraints.map((rule, i) =>
  ({...rule, lower: i === 1 ? -3 : -1000}))};
const lateError = {...twoSided, queries: unknown.queries};
const longIds = {...twoSided, constraints: twoSided.constraints.map(rule =>
  ({...rule, id: rule.id.padEnd(64, '-')}))};
const explicitNull = {...manyConstraints, constraints: manyConstraints.constraints.map(rule =>
  ({lower: null, ...rule}))};
const badConstraint = {...twoSided, constraints: twoSided.constraints.with(-1,
  {...twoSided.constraints.at(-1), zeta: 0, alpha: 0})};
const cases = constraintFields ? [
  {name: 'ordinary', requests: 64, inputs: [feasible(names.slice(0, 4), 4)]},
  {name: 'dense-one-sided', requests: 12, inputs: [manyConstraints]},
  {name: 'dense-two-sided', requests: 12, inputs: [twoSided]},
  {name: 'dense-explicit-null', requests: 12, inputs: [explicitNull]},
  {name: 'dense-late-field-error', requests: 12, inputs: [badConstraint]},
] : model ? [
  {name: 'ordinary', requests: 64, inputs: [feasible(names.slice(0, 4), 4)]},
  {name: 'dense-one-sided', requests: 12, inputs: [manyConstraints]},
  {name: 'dense-two-sided', requests: 12, inputs: [twoSided]},
  {name: 'dense-long-ids', requests: 12, inputs: [longIds]},
  {name: 'dense-late-error', requests: 12, inputs: [lateError]},
] : [
  ...(preflight || profilePreflight ? [{
    name: 'near-byte-limit', requests: 1, inputs: [feasible(names.slice(0, 4), 4)], pad: true,
  }] : []),
  {name: 'ordinary', requests: 64, inputs: [feasible(names.slice(0, 4), 4)]},
  {name: 'assignment-only', requests: 64, inputs: [feasible(names, 0)]},
  {name: 'four-queries', requests: 64, inputs: [feasible(names, 4)]},
  {name: '256-queries', requests: 64, inputs: [feasible(names, 256)]},
  ...(requests ? [{name: 'dense-model', requests: 12, inputs: [manyConstraints]}] : []),
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
function instrumentRequests(source) {
  source = source.replaceAll('\r\n', '\n');
  const analyze = 'function _M0FP210JingLan0v03stn7analyze(';
  const start = source.indexOf(analyze);
  const end = source.indexOf('\nfunction ', start + analyze.length);
  assert(start >= 0 && end > start);
  let body = source.slice(start, end);
  const beginQueries = /^    (?:const queries = \[\]|let queries);$/m;
  const endQueries = /^    const .* = _M0FP210JingLan0v03stn17arcs__with__index\(/m;
  assert(beginQueries.test(body) && endQueries.test(body), 'Missing generated query markers');
  body = body
    .replace(beginQueries, '    const queryStarted = performance.now();\n$&')
    .replace(endQueries, '    numericResultPhases.queryMs += performance.now() - queryStarted;\n$&');
  const symbols = {
    decodeMs: '_M0FP210JingLan0v03stn11parse__json',
    ...(profilePreflight ? {grammarMs: '_M0FPC14json13parse_2einner'} : {}),
    modelMs: '_M0FP210JingLan0v03stn14parse__network',
  };
  const header = ['globalThis.numericResultPhases = {decodeMs:0,modelMs:0,queryMs:0};'];
  for (const [key, fn] of Object.entries(symbols)) {
    assert(source.includes('function ' + fn + '('), 'Missing compiler function ' + fn);
    header.push('const saved_' + key + ' = ' + fn + '; ' + fn + ' = (...args) => {',
      'const start = performance.now(); try { return saved_' + key + '(...args); }',
      'finally { numericResultPhases.' + key + ' += performance.now() - start; } };');
  }
  if (profilePreflight) header.push('numericResultPhases.grammarMs = 0;');
  return header.join('\n') + '\n' + source.slice(0, start) + body + source.slice(end);
}
function instrumentModel(source) {
  const phases = {
    modelMs: '14parse__network', fieldsMs: '6fields', validationMs: '14compile__edges\\w*',
    reindexMs: '17arcs__with__index',
  };
  const header = ['globalThis.numericResultPhases = ' +
    JSON.stringify(Object.fromEntries(Object.keys(phases).map(key => [key, 0]))) + ';'];
  for (const [key, suffix] of Object.entries(phases)) {
    const symbols = [...source.matchAll(new RegExp('^function (_M0FP210JingLan0v03stn' + suffix + ')\\(', 'gm'))];
    assert(symbols.length > 0 || key === 'reindexMs', 'Missing compiler function ' + suffix);
    for (const [i, [, fn]] of symbols.entries()) {
      const saved = `saved_${key}_${i}`;
      header.push(`const ${saved} = ${fn}; ${fn} = (...args) => {`,
        `const start = performance.now(); try { return ${saved}(...args); }`,
        `finally { numericResultPhases.${key} += performance.now() - start; } };`);
    }
  }
  return header.join('\n') + '\n' + source;
}
function instrumentConstraints(source) {
  const phases = {
    modelMs: ['14parse__network'],
    constraintFieldsMs: ['6fields', 'args[1].length === 5'],
    requiredLookupMs: ['8required', 'args[1] === "id" || args[1] === "from" || args[1] === "to"'],
    boundMs: ['5bound'],
    numberMs: ['16bounded__integer', 'args[1] === -1000000'],
    constraintMs: ['17parse__constraint'],
  };
  const header = ['globalThis.numericResultPhases = ' +
    JSON.stringify(Object.fromEntries(Object.keys(phases).map(key => [key, 0]))) + ';'];
  for (const [key, [suffix, filter]] of Object.entries(phases)) {
    const fn = '_M0FP210JingLan0v03stn' + suffix;
    if (!source.includes('function ' + fn + '(')) {
      assert(['boundMs', 'constraintMs'].includes(key), 'Missing compiler function ' + suffix);
      continue;
    }
    header.push(`const saved_${key} = ${fn}; ${fn} = (...args) => {`,
      ...(filter ? [`if (!(${filter})) return saved_${key}(...args);`] : []),
      `const start = performance.now(); try { return saved_${key}(...args); }`,
      `finally { numericResultPhases.${key} += performance.now() - start; } };`);
  }
  return header.join('\n') + '\n' + source;
}
const exactUpper = new Map([['0:1', 5], ['0:2', 2], ['1:2', -3]]);
const twoSidedUpper = new Map([...exactUpper, ['1:0', 1000], ['2:0', 1003], ['2:1', 3]]);
function checkResult(actual, request) {
  if (request === badConstraint) {
    assert.deepEqual(actual, {status: 'error', code: 'invalid_input', message: 'unknown field: zeta'});
    return;
  }
  if (request === noBudget || request === unknown || request === lateError) {
    assert.equal(actual.status, 'error');
    assert.equal(actual.code, request === noBudget ? 'limit_exceeded' : 'invalid_input');
    if (request !== noBudget) assert.equal(actual.message, 'unknown timepoint: ' + unknown.queries[0].from);
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
  const upper = request === twoSided || request === longIds ? twoSidedUpper : exactUpper;
  assert.deepEqual(actual.bounds, request.queries.map(({from, to}, i) => {
    const [a, b] = pairs[i];
    const reverse = upper.get(b + ':' + a);
    return {from, to, lower: a === b ? 0 : reverse === undefined ? null : -reverse,
      upper: a === b ? 0 : upper.get(a + ':' + b) ?? null};
  }));
}
const variants = candidate ? [['baseline', baseline], ['candidate', candidate]] : [['baseline', baseline]];
const tmp = profiling ? mkdtempSync(resolve('_build', 'numeric-result-profile-')) : null;
let active = variants;
try {
  if (tmp) {
    active = variants.map(([label, file]) => {
      const target = resolve(tmp, label + '.js');
      const applyProfile = profileConstraints ? instrumentConstraints : profileModel ? instrumentModel :
        (profilePreflight || profileRequests) ? instrumentRequests : instrument;
      writeFileSync(target, applyProfile(readFileSync(file, 'utf8')));
      return [label, target];
    });
  }
  const rows = [];
  for (const {name, requests, inputs, pad} of cases) {
    const batch = Array.from({length: requests}, (_, i) => inputs[i % inputs.length]);
    const payload = JSON.stringify(batch);
    const input = pad ? payload.padEnd(1048576, ' ') : payload;
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
        if (profileConstraints) {
          assert(sample.modelMs > 0 && sample.numberMs > 0);
          assert(sample.constraintFieldsMs > 0 || sample.constraintMs > 0);
        } else if (profileModel) {
          assert(sample.modelMs > 0 && sample.fieldsMs > 0 && sample.validationMs > 0);
        } else if (profilePreflight) {
          assert(sample.decodeMs >= sample.grammarMs && sample.grammarMs > 0);
          sample.preflightMs = sample.decodeMs - sample.grammarMs;
        } else if (profileRequests) assert(sample.decodeMs > 0 && sample.modelMs > 0);
        else if (profiling) assert(sample.stringifyMs > 0);
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
