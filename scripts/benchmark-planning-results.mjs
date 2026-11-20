import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {basename, resolve} from 'node:path';
import {performance} from 'node:perf_hooks';
import {createHash} from 'node:crypto';
import {largerPlanningCases} from './verify-planning-larger.mjs';

const [baseline, candidate] = process.argv.slice(2).map(file => resolve(file));
assert(baseline, 'Pass the baseline CLI and optionally the candidate CLI');
const profileFields = process.env.MOONSTN_PROFILE_PLAN_FIELDS === '1';
const benchFields = profileFields || process.env.MOONSTN_BENCH_PLAN_FIELDS === '1';
const benchEndpoints = process.env.MOONSTN_BENCH_PLAN_ENDPOINTS === '1';
const example = name => JSON.parse(readFileSync(new URL('../examples/' + name + '-plan.json', import.meta.url)));
const {req: full} = largerPlanningCases().find(test => test.name === 'capacity-exact');
const max = {...full, tasks: full.tasks.map(task => ({...task, resource: null}))};
const wide = {tasks: Array.from({length: 24}, (_, i) => ({
  id: ('task-' + i).padEnd(64, '-'), min_duration: 2, max_duration: 2, release: i * 41233, deadline: 1000000,
}))};
const noPlan = example('impossible');
const exhausted = {...example('maintenance'), max_work: 1};
const omitted = {...max, tasks: max.tasks.map(({resource, ...task}) => task),
  dependencies: max.dependencies.map(({max_lag, ...dependency}) => dependency)};
const explicitNulls = {...max, dependencies: max.dependencies.map(d => ({...d, max_lag: null}))};
const optionalValues = {...max, tasks: max.tasks.map((task, i) => ({...task, resource: 'r' + i}))};
const badTask = {...max, tasks: max.tasks.with(-1, {...max.tasks.at(-1), zeta: 0, alpha: 0})};
const badDependency = {...max, dependencies: max.dependencies.with(-1,
  {...max.dependencies.at(-1), zeta: 0, alpha: 0})};
const longId = id => id.padStart(64, 'x');
const longEndpoints = {...max, tasks: max.tasks.map(t => ({...t, id:longId(t.id)})),
  dependencies: max.dependencies.map(d => ({...d, before:longId(d.before), after:longId(d.after)}))};
const unknownEndpoint = {...max, dependencies: max.dependencies.with(-1,
  {...max.dependencies.at(-1), after: 'missing-after'})};
const cases = [
  ['maintenance', () => [example('maintenance'), 'planned']],
  ['max-model', () => [max, 'planned']],
  ['wide-schedule', () => [wide, 'planned']],
  ['unschedulable', () => [noPlan, 'unschedulable']],
  ['budget-limit', () => [exhausted, 'error']],
  ['mixed', i => [[wide, noPlan, exhausted][i % 3], ['planned', 'unschedulable', 'error'][i % 3]]],
  ...(benchFields ? [
    ['optional-omitted', () => [omitted, 'planned']],
    ['optional-null', () => [explicitNulls, 'planned']],
    ['optional-values', () => [optionalValues, 'planned']],
    ['late-task-field', () => [badTask, 'error', 'invalid_input', 'unknown field: zeta']],
    ['late-dependency-field', () => [badDependency, 'error', 'invalid_input', 'unknown field: zeta']],
  ] : []),
  ...(benchEndpoints ? [
    ['long-endpoints', () => [longEndpoints, 'planned'], 32],
    ['late-unknown-endpoint', () => [unknownEndpoint, 'error', 'invalid_input', 'unknown task: missing-after']],
  ] : []),
];
const probe = 'data:text/javascript,' + encodeURIComponent(
  'process.once("exit", () => console.error(JSON.stringify({peakRssKiB: process.resourceUsage().maxRSS, ...globalThis.resultPhases})));',
);

function invoke(cli, input) {
  const start = performance.now();
  const run = spawnSync(process.execPath, ['--import', probe, cli, '--plan-batch', '-'], {
    input, encoding: 'utf8', timeout: 15000, maxBuffer: 4 * 1024 * 1024,
  });
  const elapsedMs = performance.now() - start;
  assert.ifError(run.error);
  assert.equal(run.status, 0, run.stderr);
  const phases = JSON.parse(run.stderr);
  assert(Number.isInteger(phases.peakRssKiB) && phases.peakRssKiB > 0);
  return {stdout: run.stdout, sample: {elapsedMs, ...phases}};
}

function instrument(cli, destination) {
  let source = readFileSync(cli, 'utf8');
  const analyze = 'function _M0FP210JingLan0v03stn13analyze__plan(';
  const start = source.indexOf(analyze);
  const end = source.indexOf('\nfunction ', start + analyze.length);
  assert(start >= 0 && end > start, 'Missing compiler function for planning');
  const body = source.slice(start, end);
  const timer = /^([ \t]*)const out =/m;
  const result = /^([ \t]*)return .*Json6Object\(out\)\);/m;
  assert(timer.test(body) && result.test(body), 'Missing compiler markers for result construction');
  source = source.slice(0, start) + body
    .replace(timer, '$1const resultStarted = performance.now();\n$&')
    .replace(result, '$1globalThis.resultPhases.resultBuildMs += performance.now() - resultStarted;\n$&') +
    source.slice(end);
  const symbols = {
    errorBuildMs: '_M0FP210JingLan0v03stn11error__json',
    stringifyMs: '_M0MPC14json4Json17stringify_2einner',
  };
  const header = ['globalThis.resultPhases = {resultBuildMs: 0, errorBuildMs: 0, stringifyMs: 0};'];
  for (const [name, fn] of Object.entries(symbols)) {
    assert(source.includes('function ' + fn + '('), 'Missing compiler function ' + fn);
    header.push('const saved_' + name + ' = ' + fn + '; ' + fn + ' = (...args) => {',
      'const start = performance.now(); try { return saved_' + name + '(...args); }',
      'finally { globalThis.resultPhases.' + name + ' += performance.now() - start; } };');
  }
  writeFileSync(destination, header.join('\n') + '\n' + source);
}

function instrumentFields(cli, destination) {
  const source = readFileSync(cli, 'utf8');
  const analyze = '_M0FP210JingLan0v03stn13analyze__plan';
  const build = '_M0FP210JingLan0v03stn17planning__problem';
  const probes = [
    ['taskFieldsMs', '_M0FP210JingLan0v03stn6fields', 'args[1].length === 6'],
    ['dependencyFieldsMs', '_M0FP210JingLan0v03stn6fields', 'args[1].length === 5'],
    ['requiredMs', '_M0FP210JingLan0v03stn8required', 'args[1] !== "tasks"'],
    ['optionalLookupMs', '_M0MPB3Map3getGsRPB4JsonE', 'args[1] === "resource" || args[1] === "max_lag"'],
    ['integerMs', '_M0FP210JingLan0v03stn9plan__int', 'true'],
  ];
  for (const fn of [analyze, build, ...probes.map(([,fn]) => fn)]) {
    assert(source.includes('function ' + fn + '('), 'Missing compiler function ' + fn);
  }
  const prefix = [
    'globalThis.resultPhases = ' + JSON.stringify(Object.fromEntries([['requestFieldsMs', 0],
      ...probes.map(([key]) => [key, 0])])) + ';',
    'let requestStart;',
    'const savedAnalyze = ' + analyze + '; ' + analyze + ' = value => {',
    'requestStart = performance.now(); try { return savedAnalyze(value); }',
    'finally { if (requestStart !== undefined) resultPhases.requestFieldsMs += performance.now() - requestStart; requestStart = undefined; } };',
    'const savedBuild = ' + build + '; ' + build + ' = (...args) => {',
    'if (requestStart !== undefined) resultPhases.requestFieldsMs += performance.now() - requestStart;',
    'requestStart = undefined; return savedBuild(...args); };',
  ];
  for (const [name, fn, condition] of probes) {
    prefix.push('const saved_' + name + ' = ' + fn + '; ' + fn + ' = (...args) => {',
      'if (!(' + condition + ')) return saved_' + name + '(...args);',
      'const start = performance.now(); try { return saved_' + name + '(...args); }',
      'finally { resultPhases.' + name + ' += performance.now() - start; } };');
  }
  writeFileSync(destination, prefix.join('\n') + '\n' + source);
}

const profiling = profileFields || process.env.MOONSTN_PROFILE_RESULTS === '1';
const variants = candidate ? [['baseline', baseline], ['candidate', candidate]] : [['baseline', baseline]];
const tmp = profiling ? mkdtempSync(resolve('_build', 'result-profile-')) : null;
try {
  const profiled = new Map();
  if (tmp) {
    for (const [label, cli] of variants) {
      const out = resolve(tmp, label + '.js');
      (profileFields ? instrumentFields : instrument)(cli, out);
      profiled.set(label, out);
    }
  }

  const rows = [];
  for (const [name, fixture, requests = 64] of cases) {
    const entries = Array.from({length: requests}, (_, i) => fixture(i));
    const input = JSON.stringify(entries.map(entry => entry[0]));
    const expected = invoke(baseline, input).stdout;
    const results = JSON.parse(expected);
    assert.deepEqual(results.map(r => r.status), entries.map(entry => entry[1]));
    for (const [i, result] of results.entries()) {
      if (result.status === 'error') {
        const [, , code = 'limit_exceeded', message] = entries[i];
        assert.equal(result.code, code);
        if (message) assert.equal(result.message, message);
      }
    }
    const samples = Object.fromEntries(variants.map(([label]) => [label, []]));
    for (let pair = 0; pair < 11; pair++) {
      for (const [label, cli] of (pair % 2 ? variants.toReversed() : variants)) {
        const {stdout, sample} = invoke(profiled.get(label) ?? cli, input);
        assert.equal(stdout, expected, name + ' output differs');
        if (profileFields) assert(sample.requestFieldsMs > 0);
        if (pair >= 2) samples[label].push(sample);
      }
    }
    rows.push({name, requests: results.length, inputBytes: Buffer.byteLength(input), outputBytes: Buffer.byteLength(expected),
      inputSha256: createHash('sha256').update(input).digest('hex'),
      outputSha256: createHash('sha256').update(expected).digest('hex'), samples});
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(),
    drivers: variants.map(([,file]) => basename(file)), profiling, profileFields,
    warmupPairs: 2, measuredPairs: 9, rows}, null, 2));
} finally {
  if (tmp) {
    for (const [label] of variants) rmSync(resolve(tmp, label + '.js'), {force: true});
    rmdirSync(tmp);
  }
}
