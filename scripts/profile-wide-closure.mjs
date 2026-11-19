import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';

const [driver] = process.argv.slice(2);
assert(driver, 'Pass a release JS library driver built with MoonSTN 0.2.18');
const source = readFileSync(resolve(driver), 'utf8').replaceAll('\r\n', '\n');
const start = source.indexOf('function _M0FP210JingLan0v03stn14solve__indexed(');
const end = source.indexOf('\nfunction ', start + 1);
assert(start >= 0 && end > start);
let body = source.slice(start, end);
const loop = '  let _tmp$3 = 0;\n  while (true) {\n    const k =';
const column = /^( +)(const \S+ = .*?Array2atGRPB5ArrayGOlEE\(via, j\);)$/m;
const returned = /^  return .*Outcome8Feasible.*_values, distances\)\)\);$/m;
assert(body.includes(loop) && column.test(body) && returned.test(body), 'Missing 0.2.18 wide closure markers');
const tmp = mkdtempSync(resolve('_build', 'wide-closure-profile-'));
const instrumented = resolve(tmp, 'probe.js');
try {
  const rows = [];
  for (const mode of ['timing', 'column-counts']) {
    let marked = body.replace(loop, '  const closureStart = performance.now();\n' + loop)
      .replace(returned, '  phase.closureMs += performance.now() - closureStart;\n  phase.solves++;\n$&');
    if (mode === 'column-counts') {
      marked = marked.replace(column, (_, pad, stmt) => {
        const name = stmt.split(' ')[1];
        return pad + stmt + '\n' + pad + 'phase.columns++; if (' + name + ' === undefined) phase.misses++;';
      });
    }
    const probe = 'const phase = {solves:0, closureMs:0, columns:0, misses:0};\n' +
      'process.once("exit", () => console.error(JSON.stringify(phase)));\n';
    writeFileSync(instrumented, probe + source.slice(0, start) + marked + source.slice(end));
    for (const shape of ['disconnected', 'chain', 'branches', 'signed-branches', 'chain-groups', 'edited-wide']) {
      const samples = [];
      for (let i = 0; i < (mode === 'timing' ? 5 : 1); i++) {
        const run = spawnSync(process.execPath, [instrumented, shape, 'default'], {encoding:'utf8', timeout:20000});
        assert.ifError(run.error);
        assert.equal(run.status, 0, run.stderr);
        const phase = JSON.parse(run.stderr);
        assert.equal(phase.solves, (shape === 'disconnected' ? 2048 : 128) * 12);
        assert(phase.closureMs > 0 && phase.misses <= phase.columns);
        samples.push(phase);
      }
      rows.push({mode, shape, samples});
    }
  }
  console.log(JSON.stringify({node: process.version, recordedAt: new Date().toISOString(), rows}, null, 2));
} finally {
  rmSync(instrumented, {force:true});
  rmdirSync(tmp);
}
