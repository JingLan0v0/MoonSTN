import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';

const [driver] = process.argv.slice(2);
assert(driver, 'Pass the 0.2.10 release numeric library benchmark driver');
const source = readFileSync(resolve(driver), 'utf8').replaceAll('\r\n', '\n');
const symbol = '_M0FP210JingLan0v03stn17narrow__distances';
const begin = source.indexOf('function ' + symbol + '(');
const end = source.indexOf('\nfunction ', begin + symbol.length);
assert(begin >= 0 && end > begin, 'Missing narrow closure compiler symbol');
let body = source.slice(begin, end);
function mark(marker, addition) {
  assert(body.includes(marker), 'Missing compiler phase marker');
  body = body.replace(marker, addition + '\n' + marker);
}
mark('  let _tmp$3 = 0;\n  while (true) {\n    const k =', '  const closureStart = performance.now();');
mark('  let _tmp$4;\n  if (n <= 0)', '  const widenStart = performance.now();\n  phases.closure += widenStart - closureStart;');
mark('  return new _M0DTPC16result6ResultGORPB5ArrayGRPB5ArrayGOlEERP210JingLan0v03stn8StnErrorE2Ok(new',
  '  phases.widen += performance.now() - widenStart;');
const index = '_M0FP210JingLan0v03stn13indexed__arcs';
assert(source.includes('function ' + index + '('));
const setup = 'const phases = {index: 0, closure: 0, widen: 0, solves: 0};\n' +
  'const originalIndex = ' + index + ';\n' + index + ' = (...args) => {\n' +
  '  const start = performance.now();\n' +
  '  try { return originalIndex(...args); }\n' +
  '  finally { phases.index += performance.now() - start; phases.solves++; }\n' +
  '};\nprocess.once("exit", () => console.error(JSON.stringify(phases)));\n';
const tmp = mkdtempSync(resolve('_build', 'numeric-profile-'));
const instrumented = resolve(tmp, 'probe.js');
try {
  writeFileSync(instrumented, setup + source.slice(0, begin) + body + source.slice(end));
  const rows = [];
  for (const [shape, budget] of [['disconnected', 'default'], ['chain', 'default'],
    ['connected', 'default'], ['connected', 'exhausted']]) {
    const samples = [];
    for (let i = 0; i < 7; i++) {
      const r = spawnSync(process.execPath, [instrumented, shape, budget], {encoding: 'utf8', timeout: 15000});
      assert.ifError(r.error);
      assert.equal(r.status, 0, r.stderr);
      assert.equal(r.stdout.trim().split(/\r?\n/).length, 9);
      const result = JSON.parse(r.stderr);
      assert.equal(result.solves, (shape === 'disconnected' ? 2048 : 128) * 12);
      if (shape === 'connected' && budget === 'default') {
        assert(result.closure > 0 && result.widen > 0);
      } else {
        assert.equal(result.widen, 0);
        assert.equal(result.closure, 0);
      }
      if (i > 0) samples.push(result);
    }
    rows.push({shape, budget, samples});
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(),
    warmupsPerProcess: 3, measuredPerProcess: 9, rows}, null, 2));
} finally {
  rmSync(instrumented, {force: true});
  rmdirSync(tmp);
}
