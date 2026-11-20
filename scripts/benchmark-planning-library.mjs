import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';

assert.equal(process.argv.length, 4, 'Pass the compiled baseline and candidate benchmark drivers');
const labels = ['baseline', 'candidate'];
const cli = Object.fromEntries(labels.map((label, i) => [label, resolve(process.argv[i + 2])]));
const profile = process.env.MOONSTN_PROFILE_PLAN_ENDPOINTS === '1';
const construction = profile || process.env.MOONSTN_BENCH_PLAN_CONSTRUCTION === '1';
const cases = construction ? ['construct-small-none', 'construct-small-linked', 'construct-large-none',
  'construct-early', 'construct-spread', 'construct-long', 'construct-late-unknown',
  ...(process.env.MOONSTN_BENCH_PLAN_ID_LENGTHS === '1' ? ['construct-id-8', 'construct-id-16', 'construct-id-32'] : [])] :
  ['maintenance', 'independent', 'distinct-resources', 'first-pair', 'last-pair',
  'four-resources', 'one-resource', 'max-root', 'max-model'];

function instrument(file) {
  let source = readFileSync(file, 'utf8').replaceAll('\r\n', '\n');
  const fn = '_M0FP210JingLan0v03stn11task__index';
  const start = source.indexOf('function ' + fn + '(');
  const end = source.indexOf('\nfunction ', start + 1);
  assert(start >= 0 && end > start, 'Missing generated endpoint lookup');
  const compare = /^([ \t]*)if \(.*\.id === id\) \{/m;
  const mapLookup = /^([ \t]*)const [^\n]+ = _M0MPB3Map3get\w+\(/m;
  const body = source.slice(start, end)
    .replace(compare, '$1endpointProfile.comparisons++;\n$&')
    .replace(mapLookup, '$1endpointProfile.mapLookups++;\n$&');
  source = source.slice(0, start) + body + source.slice(end);
  return `const endpointProfile = {calls:0, comparisons:0, mapLookups:0, lookupMs:0};
    const savedLookup = ${fn}; ${fn} = (...args) => {
      endpointProfile.calls++;
      const start = performance.now(); try { return savedLookup(...args); }
      finally { endpointProfile.lookupMs += performance.now() - start; }
    };
    process.once('exit', () => console.error(JSON.stringify(endpointProfile)));
    ${source}`;
}

const scratch = profile ? mkdtempSync(resolve('_build', 'planning-endpoint-profile-')) : null;
try {
  const active = scratch ? Object.fromEntries(labels.map(label => {
    const file = resolve(scratch, label + '.js');
    writeFileSync(file, instrument(cli[label]));
    return [label, file];
  })) : cli;
  const rows = cases.map(name => {
    const samples = {baseline: [], candidate: []};
    const phases = {baseline: [], candidate: []};
    let expected;
    for (let pair = 0; pair < 3; pair++) {
      for (const label of pair % 2 === 0 ? labels : labels.toReversed()) {
        const result = spawnSync(process.execPath, [active[label], name], {encoding: 'utf8', timeout: 30000});
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
        if (profile) phases[label].push(JSON.parse(result.stderr));
      }
    }
    const medianMs = Object.fromEntries(labels.map(label => {
      const sorted = samples[label].flat().toSorted((a, b) => a - b);
      return [label, sorted[Math.floor(sorted.length / 2)]];
    }));
    return {name, medianMs, samples, work: expected[0], checksum: expected[1], ...(profile ? {phases} : {})};
  });
  console.log(JSON.stringify({
    recordedAt: new Date().toISOString(), node: process.version, callsPerSample: construction ? 1000 : 500,
    construction, profile,
    processPairs: 3, warmupsPerProcess: 3, rows,
  }, null, 2));
} finally {
  if (scratch) {
    for (const label of labels) rmSync(resolve(scratch, label + '.js'), {force: true});
    rmdirSync(scratch);
  }
}
