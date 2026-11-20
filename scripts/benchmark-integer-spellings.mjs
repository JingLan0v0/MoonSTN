import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {basename, resolve} from 'node:path';

const [baseline, candidate] = process.argv.slice(2).map(file => resolve(file));
assert(baseline, 'Pass the baseline CLI and optionally a candidate CLI');
const profile = process.env.MOONSTN_PROFILE_INTEGER_SPELLINGS === '1';
const kernel = process.env.MOONSTN_BENCH_INTEGER_KERNEL === '1';
const spelling = '_M0FP210JingLan0v03stn17integer__spelling';
const plain = String;
const decimal = n => n + '.000000';
const exponent = n => n === 0 ? '-0E+999999999999' : n + '000E-3';
const long = n => n + '.' + '0'.repeat(160);

function numeric(count, format, bad = false) {
  const rules = Array.from({length: count}, (_, i) =>
    `{"id":"c${i}","from":"a","to":"b","lower":${format(-4)},"upper":${bad && i === count - 1 ? long(5) + '1' : format(5)}}`);
  return `{"timepoints":["a","b"],"constraints":[${rules}],"queries":[{"from":"a","to":"b"}]}`;
}

function planning(count, format) {
  const tasks = Array.from({length: count}, (_, i) =>
    `{"id":"t${i}","min_duration":${format(1)},"max_duration":${format(1)},"release":${format(2)},"deadline":${format(20)}}`);
  const dependencies = Array.from({length: count === 24 ? 64 : 0}, (_, i) =>
    `{"before":"t${i % count}","after":"t${(i + 1 + Math.floor(i / count)) % count}","kind":"SS","min_lag":${format(0)},"max_lag":${format(5)}}`);
  return `{"tasks":[${tasks}],"dependencies":[${dependencies}]}`;
}

const cases = [
  {name: 'numeric-ordinary', requests: 64, raw: numeric(2, plain)},
  {name: 'numeric-plain', requests: 12, raw: numeric(512, plain)},
  {name: 'numeric-decimal', requests: 10, raw: numeric(512, decimal)},
  {name: 'numeric-exponent', requests: 10, raw: numeric(512, exponent)},
  {name: 'numeric-long-decimal', requests: 1, raw: numeric(512, long)},
  {name: 'numeric-late-fraction', requests: 1, raw: numeric(512, long, true), error: true},
  {name: 'planning-ordinary', requests: 64, tasks: 1, raw: planning(1, plain)},
  {name: 'planning-plain', requests: 64, tasks: 24, raw: planning(24, plain)},
  {name: 'planning-decimal', requests: 50, tasks: 24, raw: planning(24, decimal)},
  {name: 'planning-exponent', requests: 50, tasks: 24, raw: planning(24, exponent)},
  {name: 'planning-long-decimal', requests: 4, tasks: 24, raw: planning(24, long)},
];

const exitProbe = 'data:text/javascript,' + encodeURIComponent(
  'process.once("exit", () => console.error(JSON.stringify({peakRssKiB: process.resourceUsage().maxRSS, ...globalThis.integerPhases})));',
);

function invoke(cli, flag, input) {
  const start = performance.now();
  const result = spawnSync(process.execPath, ['--import', exitProbe, cli, flag, '-'], {
    input, encoding: 'utf8', timeout: 15000, maxBuffer: 4 * 1024 * 1024,
  });
  const elapsedMs = performance.now() - start;
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stderr);
  const phases = JSON.parse(result.stderr);
  assert(phases.peakRssKiB > 0);
  return {output: result.stdout, sample: {elapsedMs, ...phases}};
}

function instrument(source) {
  const decode = '_M0FP210JingLan0v03stn11parse__json';
  for (const fn of [spelling, decode]) assert(source.includes('function ' + fn + '('), fn);
  return `globalThis.integerPhases = {spellingMs:0, decodeMs:0, spellingCalls:0, spellingUnits:0};
    const savedSpelling = ${spelling}; ${spelling} = value => {
      integerPhases.spellingCalls++; integerPhases.spellingUnits += value.length;
      const start = performance.now(); try { return savedSpelling(value); }
      finally { integerPhases.spellingMs += performance.now() - start; }
    };
    const savedDecode = ${decode}; ${decode} = value => {
      const start = performance.now(); try { return savedDecode(value); }
      finally { integerPhases.decodeMs += performance.now() - start; }
    };
    ${source}`;
}

function check(result, fixture) {
  if (fixture.error) {
    assert.deepEqual(result, {status: 'error', code: 'invalid_input',
      message: 'upper must be null or an integer in -1000000..1000000'});
  } else if (fixture.tasks) {
    assert.equal(result.status, 'planned');
    assert.equal(result.schedule.length, fixture.tasks);
    result.schedule.forEach((task, i) => {
      assert.equal(task.id, 't' + i);
      assert(task.start >= 2 && task.finish <= 20 && task.finish - task.start === 1);
      for (let jump = 1; fixture.tasks === 24 && jump <= 3; jump++) {
        if (jump === 3 && i >= 16) break;
        const gap = result.schedule[(i + jump) % fixture.tasks].start - task.start;
        assert(gap >= 0 && gap <= 5);
      }
    });
  } else {
    assert.deepEqual(result, {status: 'feasible', assignment: {a: 0, b: 0},
      bounds: [{from: 'a', to: 'b', lower: -4, upper: 5}]});
  }
}

function kernelMeasurements(variants) {
  const drivers = variants.map(([label, file]) => {
    const source = readFileSync(file, 'utf8');
    const body = source.match(new RegExp('^function ' + spelling + '\\(source\\) \\{[\\s\\S]*?^\\}', 'm'));
    assert(body, 'Missing generated spelling function in ' + file);
    const compile = new Function('$oob', body[0] + '\nreturn ' + spelling + ';');
    return [label, compile(() => { throw new RangeError('Unexpected spelling index'); })];
  });
  const zeros = '0'.repeat(160);
  const nines = '9'.repeat(512);
  const inputs = [
    ['ordinary integers', 100000, [['0',true], ['5',true], ['-4',true], ['10000000',true]]],
    ['decimals', 100000, [['5.000000',true], ['-4.000000',true], ['0.125',false], ['1.00000000000001',false]]],
    ['exponents', 100000, [['100e-2',true], ['0.0001E+4',true], ['10e-2',false], ['1e-400',false]]],
    ['long fractional tails', 6000, [['5.'+zeros,true], ['5.'+zeros+'1',false], ['-0.'+zeros,true]]],
    ['long exponents', 2500, [['1e-'+nines,false], ['-0E-'+nines,true], ['50e-'+'0'.repeat(512)+'1',true]]],
  ];
  const rows = inputs.map(([name, iterations, cases]) => {
    for (const [, run] of drivers) {
      for (const [source, expected] of cases) assert.equal(run(source), expected, source);
    }
    const spellings = cases.map(([source]) => source);
    const accepted = cases.filter(([, expected]) => expected).length * iterations;
    const samples = Object.fromEntries(variants.map(([label]) => [label, []]));
    for (let pair = 0; pair < 11; pair++) {
      for (const [label, run] of pair % 2 ? drivers.toReversed() : drivers) {
        let count = 0;
        const start = performance.now();
        for (let i = 0; i < iterations; i++) {
          for (const source of spellings) count += Number(run(source));
        }
        const elapsedMs = performance.now() - start;
        assert.equal(count, accepted);
        if (pair >= 2) samples[label].push({elapsedMs});
      }
    }
    return {name, callsPerSample: iterations * spellings.length, samples};
  });
  return {node: process.version, recordedAt: new Date().toISOString(),
    drivers: variants.map(([, file]) => basename(file)), kernel: true, warmupPairs: 2, measuredPairs: 9, rows};
}

const variants = candidate ? [['baseline', baseline], ['candidate', candidate]] : [['baseline', baseline]];
if (kernel) {
  writeFileSync(1, JSON.stringify(kernelMeasurements(variants), null, 2) + '\n');
  process.exit(0);
}
const tmp = profile ? mkdtempSync(resolve('_build', 'integer-spelling-profile-')) : null;
try {
  const active = tmp ? variants.map(([label, file]) => {
    const target = resolve(tmp, label + '.js');
    writeFileSync(target, instrument(readFileSync(file, 'utf8')));
    return [label, target];
  }) : variants;
  const rows = [];
  for (const fixture of cases) {
    const {name, requests, raw, tasks} = fixture;
    const input = '[' + Array(requests).fill(raw).join(',') + ']';
    assert(input.length <= 1048576, name + ' exceeds the byte limit');
    assert(input.replace(/"[^"]*"/g, '"').length <= 200000, name + ' exceeds the scan limit');
    const flag = tasks ? '--plan-batch' : '--batch';
    const expected = invoke(baseline, flag, input).output;
    const results = JSON.parse(expected);
    assert.equal(results.length, requests);
    results.forEach(result => check(result, fixture));
    const samples = Object.fromEntries(variants.map(([label]) => [label, []]));
    for (let pair = 0; pair < 11; pair++) {
      for (const [label, cli] of pair % 2 ? active.toReversed() : active) {
        const {output, sample} = invoke(cli, flag, input);
        assert.equal(output, expected, name + '/' + label);
        if (profile) assert(sample.spellingCalls > 0 && sample.spellingUnits > 0 && sample.spellingMs > 0);
        if (pair >= 2) samples[label].push(sample);
      }
    }
    rows.push({name, requests, inputBytes: Buffer.byteLength(input), outputBytes: Buffer.byteLength(expected),
      outputSha256: createHash('sha256').update(expected).digest('hex'), samples});
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(),
    drivers: variants.map(([, file]) => basename(file)), profile, warmupPairs: 2, measuredPairs: 9, rows}, null, 2));
} finally {
  if (tmp) {
    for (const [label] of variants) rmSync(resolve(tmp, label + '.js'), {force: true});
    rmdirSync(tmp);
  }
}
