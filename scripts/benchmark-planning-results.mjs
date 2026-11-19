import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {performance} from 'node:perf_hooks';
import {createHash} from 'node:crypto';
import {largerPlanningCases} from './verify-planning-larger.mjs';

const [baseline, candidate] = process.argv.slice(2).map(file => resolve(file));
assert(baseline, 'Pass the baseline CLI and optionally the candidate CLI');
const example = name => JSON.parse(readFileSync(new URL('../examples/' + name + '-plan.json', import.meta.url)));
const {req: full} = largerPlanningCases().find(test => test.name === 'capacity-exact');
const max = {...full, tasks: full.tasks.map(task => ({...task, resource: null}))};
const wide = {tasks: Array.from({length: 24}, (_, i) => ({
  id: ('task-' + i).padEnd(64, '-'), min_duration: 2, max_duration: 2, release: i * 41233, deadline: 1000000,
}))};
const noPlan = example('impossible');
const exhausted = {...example('maintenance'), max_work: 1};
const cases = [
  ['maintenance', () => [example('maintenance'), 'planned']],
  ['max-model', () => [max, 'planned']],
  ['wide-schedule', () => [wide, 'planned']],
  ['unschedulable', () => [noPlan, 'unschedulable']],
  ['budget-limit', () => [exhausted, 'error']],
  ['mixed', i => [[wide, noPlan, exhausted][i % 3], ['planned', 'unschedulable', 'error'][i % 3]]],
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

const profiling = process.env.MOONSTN_PROFILE_RESULTS === '1';
const variants = candidate ? [['baseline', baseline], ['candidate', candidate]] : [['baseline', baseline]];
const tmp = profiling ? mkdtempSync(resolve('_build', 'result-profile-')) : null;
try {
  const profiled = new Map();
  if (tmp) {
    for (const [label, cli] of variants) {
      const out = resolve(tmp, label + '.js');
      instrument(cli, out);
      profiled.set(label, out);
    }
  }

  const rows = [];
  for (const [name, fixture] of cases) {
    const entries = Array.from({length: 64}, (_, i) => fixture(i));
    const input = JSON.stringify(entries.map(entry => entry[0]));
    const expected = invoke(baseline, input).stdout;
    const results = JSON.parse(expected);
    assert.deepEqual(results.map(r => r.status), entries.map(entry => entry[1]));
    for (const result of results) {
      if (result.status === 'error') assert.equal(result.code, 'limit_exceeded');
    }
    const samples = Object.fromEntries(variants.map(([label]) => [label, []]));
    for (let pair = 0; pair < 11; pair++) {
      for (const [label, cli] of (pair % 2 ? variants.toReversed() : variants)) {
        const {stdout, sample} = invoke(profiled.get(label) ?? cli, input);
        assert.equal(stdout, expected, name + ' output differs');
        if (pair >= 2) samples[label].push(sample);
      }
    }
    rows.push({name, requests: results.length, outputBytes: Buffer.byteLength(expected),
      outputSha256: createHash('sha256').update(expected).digest('hex'), samples});
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(),
    profiling, warmupPairs: 2, measuredPairs: 9, rows}, null, 2));
} finally {
  if (tmp) {
    for (const [label] of variants) rmSync(resolve(tmp, label + '.js'), {force: true});
    rmdirSync(tmp);
  }
}
