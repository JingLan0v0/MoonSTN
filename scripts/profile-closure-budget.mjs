import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';

const [driver] = process.argv.slice(2);
assert(driver, 'Pass the 0.2.17 release numeric library benchmark driver');
const source = readFileSync(resolve(driver), 'utf8').replaceAll('\r\n', '\n');
const start = source.indexOf('function _M0FP210JingLan0v03stn14solve__indexed(');
const end = source.indexOf('\nfunction ', start + 1);
assert(start >= 0 && end > start);
let body = source.slice(start, end);
const allocation = '  let distances;';
const charge = /^(  const .* = _M0MP210JingLan0v03stn6Budget6charge\(budget, Math.imul[^\n]*);$/m;
assert(body.includes(allocation) && charge.test(body), 'Missing 0.2.17 wide closure markers');
body = body.replace(allocation, '  const setupStart = performance.now();\n' + allocation);
body = body.replace(charge, '  phase.wideSetupMs += performance.now() - setupStart;\n  phase.wideCalls++;\n$&');
const probe = 'const phase = {wideCalls: 0, wideSetupMs: 0};\n' +
  'process.once("exit", () => console.error(JSON.stringify(phase)));\n';
const tmp = mkdtempSync(resolve('_build', 'closure-budget-profile-'));
const marked = resolve(tmp, 'probe.js');
try {
  writeFileSync(marked, probe + source.slice(0, start) + body + source.slice(end));
  const rows = [];
  for (const shape of ['disconnected', 'chain', 'connected']) {
    const calls = shape === 'disconnected' ? 2048 : 128;
    const samples = [];
    for (let i = 0; i < 6; i++) {
      const run = spawnSync(process.execPath, [marked, shape, 'exhausted'], {encoding:'utf8', timeout:15000});
      assert.ifError(run.error);
      assert.equal(run.status, 0, run.stderr);
      const phases = JSON.parse(run.stderr);
      assert.equal(phases.wideCalls, calls * 12);
      assert(phases.wideSetupMs > 0);
      if (i > 0) samples.push(phases);
    }
    rows.push({shape, callsPerSample: calls, samples});
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(), rows}, null, 2));
} finally {
  rmSync(marked, {force:true});
  rmdirSync(tmp);
}
