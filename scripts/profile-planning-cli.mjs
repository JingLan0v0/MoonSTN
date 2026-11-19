import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {largerPlanningCases} from './verify-planning-larger.mjs';

const [cliArg, outputDir = '_build'] = process.argv.slice(2);
assert(cliArg, 'Pass the compiled release CLI');
const cli = resolve(cliArg);
const source = readFileSync(cli, 'utf8');
const symbols = {
  parse: '_M0FP210JingLan0v03stn11parse__json',
  grammar: '_M0FPC14json13parse_2einner',
  analyze: '_M0FP210JingLan0v03stn13analyze__plan',
  model: '_M0FP210JingLan0v03stn17planning__problem',
  solve: '_M0FP210JingLan0v03stn12plan_2einner',
  stringify: '_M0MPC14json4Json17stringify_2einner',
};
const wrappers = Object.entries(symbols).map(([name, fn]) => {
  assert(source.includes('function ' + fn + '('), 'Missing compiler symbol ' + fn);
  return 'const original_' + name + ' = ' + fn + ';\n' + fn + ' = (...args) => {\n' +
    '  const start = performance.now();\n' +
    '  try { return original_' + name + '(...args); }\n' +
    '  finally { phaseMs.' + name + ' += performance.now() - start; }\n' +
    '};';
});
const tmp = mkdtempSync(resolve(outputDir, 'plan-profile-'));
try {
  const instrumented = resolve(tmp, 'profile.js');
  const setup = 'const phaseMs = ' + JSON.stringify(Object.fromEntries(Object.keys(symbols).map(k => [k, 0]))) + ';\n';
  writeFileSync(instrumented, setup + wrappers.join('\n') +
    '\nprocess.once("exit", () => console.error(JSON.stringify(phaseMs)));\n' + source);
  const ordinary = JSON.parse(readFileSync(new URL('../examples/maintenance-plan.json', import.meta.url)));
  const {req: full} = largerPlanningCases().find(test => test.name === 'capacity-exact');
  const rootOnly = {...full, tasks: full.tasks.map(task => ({...task, resource: null}))};
  const profiles = [];
  for (const [name, req] of [['maintenance', ordinary], ['max-root', rootOnly], ['max-model', full]]) {
    const input = JSON.stringify(Array(64).fill(req));
    const plain = spawnSync(process.execPath, [cli, '--plan-batch', '-'], {input, encoding: 'utf8', timeout: 15000});
    assert.ifError(plain.error);
    assert.equal(plain.status, 0, plain.stderr);
    assert.equal(JSON.parse(plain.stdout).length, 64);
    assert(JSON.parse(plain.stdout).every(value => value.status === 'planned'));
    const samples = [];
    for (let round = 0; round < 8; round++) {
      const run = spawnSync(process.execPath, [instrumented, '--plan-batch', '-'], {input, encoding: 'utf8', timeout: 15000});
      assert.ifError(run.error);
      assert.equal(run.status, 0, run.stderr);
      assert.equal(run.stdout, plain.stdout);
      const {parse, grammar, analyze, model, solve, stringify} = JSON.parse(run.stderr);
      if (round > 0) samples.push({preflight: parse - grammar, grammar, model, solve,
        requestAndResult: analyze - model - solve, stringify});
    }
    profiles.push({name, inputBytes: Buffer.byteLength(input), requestsPerProcess: 64, samples});
  }
  console.log(JSON.stringify({recordedAt: new Date().toISOString(), node: process.version, profiles}, null, 2));
} finally {
  rmSync(resolve(tmp, 'profile.js'), {force: true});
  rmdirSync(tmp);
}
