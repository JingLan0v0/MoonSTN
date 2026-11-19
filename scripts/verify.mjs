import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const root=path.resolve(import.meta.dirname,'..');
process.chdir(root);
const baselineCli=process.argv[2] && path.resolve(process.argv[2]);
const summary=path.join(root,'_build/verification-summary.json');
fs.mkdirSync(path.dirname(summary),{recursive:true});fs.rmSync(summary,{force:true});
const candidates=[process.env.MOON_HOME,path.resolve(root,'../.tools/moonstn-toolchain'),path.resolve(root,'../MoonBit黑客松/.tools/moonstn-toolchain')].filter(Boolean);
const installation=candidates.find(p=>fs.existsSync(path.join(p,'bin',process.platform==='win32'?'moon.exe':'moon')));
if(installation)process.env.MOON_HOME=installation;
const moon=process.env.MOON_BIN || (installation?path.join(installation,'bin',process.platform==='win32'?'moon.exe':'moon'):'moon');
function run(cmd,args,options={}){const r=spawnSync(cmd,args,{cwd:root,encoding:'utf8',timeout:120000,maxBuffer:16*1024*1024,...options});assert.equal(r.error,undefined);assert.equal(r.status,0,r.stderr||r.stdout);return r.stdout;}
const versions=run(moon,['version','--all']);assert(versions.includes('v0.10.18+6c83a7f62'),'Use the pinned toolchain');
run(moon,['fmt','--check']);run(moon,['check','--target','js','--deny-warn']);run(moon,['info','--target','js']);
const reports=[];
const names=['a','b','c'];const pairs=[];for(let a=0;a<3;a++)for(let b=0;b<3;b++)if(a!==b)pairs.push([a,b]);
const cases=[];
for(let mask=0;mask<4096;mask++){
 let code=mask;const constraints=[];
 for(let i=0;i<6;i++){const option=code%4;code=Math.floor(code/4);if(option)constraints.push({id:`e${i}`,from:names[pairs[i][0]],to:names[pairs[i][1]],upper:option-2});}
 const queries=names.flatMap(from=>names.map(to=>({from,to})));
 const feasible=[];for(let b=-4;b<=4;b++)for(let c=-4;c<=4;c++){const x={a:0,b,c};if(constraints.every(e=>x[e.to]-x[e.from]<=e.upper))feasible.push(x);}
 // Connectivity uses reachability only, independent of numeric shortest-path algorithms.
 const reach=names.map((_,i)=>names.map((_,j)=>i===j));for(const e of constraints)reach[names.indexOf(e.from)][names.indexOf(e.to)]=true;
 for(let k=0;k<3;k++)for(let i=0;i<3;i++)for(let j=0;j<3;j++)reach[i][j] ||= reach[i][k]&&reach[k][j];
 const bounds=queries.map(({from,to})=>({from,to,lower:reach[names.indexOf(to)][names.indexOf(from)]&&feasible.length?Math.min(...feasible.map(x=>x[to]-x[from])):null,upper:reach[names.indexOf(from)][names.indexOf(to)]&&feasible.length?Math.max(...feasible.map(x=>x[to]-x[from])):null}));
 cases.push({request:{timepoints:names,constraints,queries},feasible:feasible.length>0,bounds});
}
function verifyIntegerSpellings(invoke) {
 const numeric = bound =>
   `{"timepoints":["a","b"],"constraints":[{"id":"x","from":"a","to":"b","upper":${bound}}],"queries":[{"from":"a","to":"b"}]}`;
 const planning = (release, work = '20000000') =>
   `{"t\\u0061sks":[{"id":"a","min_duration":1,"max_duration":1,"release":${release},"deadline":10}],"max_work":${work}}`;
 const variants = [
   ['--batch', numeric, '100e-2', ['1000000.00000000001', '1.00000000000000001', '1e-400']],
   ['--plan-batch', planning, '0.20e1', ['1e-400', '2.00000000000000001']],
 ];
 for (const [flag, request, exact, fractions] of variants) {
   const good = request(exact);
   const raw = '[' + [good, ...fractions.map(n => request(n)), good].join(',') + ']';
   const r = invoke([flag, '-'], raw);
   assert.equal(r.status, 0, r.stderr);
   const results = JSON.parse(r.stdout);
   assert.equal(results.length, fractions.length + 2);
   assert.deepEqual(results[0], results.at(-1));
   if (flag === '--batch') {
     assert.equal(results[0].status, 'feasible');
     assert.equal(results[0].bounds[0].upper, 1);
   } else {
     assert.equal(results[0].status, 'planned');
     assert.equal(results[0].schedule[0].start, 2);
   }
   for (const out of results.slice(1, -1)) assert.equal(out.code, 'invalid_input');
 }
 for (const [input, reason] of [
   ['{"tasks":[],"t\\u0061sks":[]}', 'invalid_json: invalid JSON text'],
   [planning('1e-400').replace('{"id"', '{"typo":1,"id"'), 'invalid_input: unknown field: typo'],
   [planning('0', '20000000.0000000000001'), 'invalid_input: expected bounded integer'],
 ]) {
   const r = invoke(['--plan', '-'], input);
   assert.equal(r.status, 2);
   assert.equal(r.stdout, '');
   assert.equal(r.stderr.trim(), reason);
 }
}
function verifyNumericEncoding(invoke) {
 const name = 'bad\n\t"\\雪';
 const good = {
   timepoints: ['10', '2', '__proto__'],
   constraints: [{id:'signed', from:'10', to:'2', upper:-2}],
   queries: [{from:'10', to:'2'}, {from:'__proto__', to:'10'}],
 };
 const cycle = {
   timepoints: ['10'],
   constraints: [{id:'zero', from:'10', to:'10', lower:1}],
 };
 const bad = {...good, queries:[{from:name, to:'2'}]};
 const goodBytes = '{"status":"feasible","assignment":{"10":0,"2":-2,"__proto__":0},"bounds":' +
   '[{"from":"10","to":"2","lower":null,"upper":-2},{"from":"__proto__","to":"10","lower":null,"upper":null}]}';
 const cycleBytes = '{"status":"inconsistent","cycle":[{"id":"zero","from":"10","to":"10","bound":-1,"side":"lower"}]}';
 const errorBytes = JSON.stringify({status:'error', code:'invalid_input', message:'unknown timepoint: '+name});
 const single = invoke(['-'], JSON.stringify(good));
 assert.equal(single.status, 0, single.stderr);
 assert.equal(single.stdout, goodBytes+'\n');
 const mixed = invoke(['--batch','-'], JSON.stringify([good,cycle,bad,good]));
 assert.equal(mixed.status, 0, mixed.stderr);
 assert.equal(mixed.stdout, '['+[goodBytes,cycleBytes,errorBytes,goodBytes].join(',')+']\n');
}
function verifyQueryErrorOrder(invoke) {
 const good = {timepoints:['a','b'], constraints:[], queries:[{to:'b',from:'a'}]};
 const cases = [
   [{from:false,zeta:0,alpha:0}, 'unknown field: zeta'],
   [{to:false}, 'missing field: from'],
   [{from:false}, 'from must be a string'],
   [{from:'a'}, 'missing field: to'],
   [{from:'x',to:false}, 'to must be a string'],
   [{from:'x',to:'y'}, 'unknown timepoint: x'],
   [{from:'a',to:'y'}, 'unknown timepoint: y'],
 ];
 const input = JSON.stringify([good, ...cases.map(([q]) => ({...good,max_steps:1,queries:[good.queries[0],q]})), good]);
 const r = invoke(['--batch','-'],input);
 assert.equal(r.status,0,r.stderr);
 const results = JSON.parse(r.stdout);
 assert.equal(results[0].status,'feasible');
 assert.deepEqual(results[0],results.at(-1));
 assert.deepEqual(results.slice(1,-1),cases.map(([,message]) => ({status:'error',code:'invalid_input',message})));
 const duplicate = invoke(['-'],'{"timepoints":["a"],"constraints":[],"queries":[{"from":"a","f\\u0072om":"a","to":"a"}]}');
 assert.equal(duplicate.status,2);
 assert.equal(duplicate.stdout,'');
 assert.equal(duplicate.stderr.trim(),'invalid_json: invalid JSON text');
}
function verifyJsonScanBounds(invoke) {
 const valid = '{"timepoints":["a"],"constraints":[]}';
 const padded = valid.padEnd(1048576, ' ');
 const decoded = invoke(['-'], padded);
 assert.equal(decoded.status,0,decoded.stderr);
 assert.equal(decoded.stdout,'{"status":"feasible","assignment":{"a":0},"bounds":[]}\n');
 const tokens = '[10,' + '0,'.repeat(99997) + '0]';
 assert.equal(tokens.length,200000);
 const unicode = '"' + '\u{1f600}'.repeat(255);
 const escaped = '"' + '\\"'.repeat(127) + 'a';
 const stringError = 'limit_exceeded: JSON string exceeds 256 source characters';
 const scanError = 'limit_exceeded: JSON nesting or token budget exceeded';
 const wrongType = 'invalid_input: network must be an object';
 const cases = [
   [padded+' ', 'io: input exceeds 1 MiB'],
   [tokens+' \r\n\t', wrongType],
   [tokens.replace('[10,','[100,'), scanError],
   ['['.repeat(16)+'0'+']'.repeat(16), wrongType],
   ['['.repeat(17)+'0'+']'.repeat(17), scanError],
   [']'+'['.repeat(17)+'0'+']'.repeat(17), 'invalid_json: invalid JSON text'],
   [unicode+'"', wrongType],
   [unicode+'x"', stringError],
   [escaped+'"', wrongType],
   [escaped+'x"', stringError],
   ['"'+' '.repeat(257), stringError],
 ];
 for (const [input, expected] of cases) {
   const out = invoke(['-'], input);
   assert.equal(out.status,2,out.error ?? out.stderr);
   assert.equal(out.stdout,'');
   assert.equal(out.stderr.trim(),expected);
 }
}
function verifyClosureBudgetOrder(invoke) {
 const names=Array.from({length:32},(_,i)=>'v'+i);
 const ring=names.flatMap((from,i)=>Array.from({length:4},(_,j)=>
   ({id:'e'+i+'-'+j,from,to:names[(i+j+1)%32],upper:1})));
 // Both cases have enough arcs to try the narrow path. Parallel arcs
 // fail its distinct-pair check and use the wide matrix.
 const parallel=ring.map(edge=>({...edge,from:'v0',to:'v1'}));
 const exact=names.length**3+2*ring.length;
 const variants=[ring,parallel].map(constraints=>({
   timepoints:names,constraints,queries:[{from:'v0',to:'v31'}],max_steps:exact,
 }));
 const cycle={timepoints:['a','b'],constraints:[{id:'loop',from:'a',to:'a',upper:-1}],max_steps:5};
 const bad={timepoints:['a'],constraints:[{id:'missing',from:'a',to:'x',upper:1}],max_steps:1};
 const input=variants.flatMap(ok=>[{...ok,max_steps:ring.length},{...ok,max_steps:exact-1},ok]);
 input.push({...cycle,max_steps:4},cycle,bad,variants[0]);
 const out=invoke(['--batch','-'],JSON.stringify(input));
 assert.equal(out.status,0,out.stderr);
 const results=JSON.parse(out.stdout);
 const exhausted={status:'error',code:'limit_exceeded',message:'work budget exhausted; no feasibility conclusion'};
 for (const i of [0,1,3,4,6]) assert.deepEqual(results[i],exhausted);
 assert.deepEqual(results[2].bounds,[{from:'v0',to:'v31',lower:-1,upper:8}]);
 assert.deepEqual(results[5].bounds,[{from:'v0',to:'v31',lower:null,upper:null}]);
 assert.deepEqual(results[7],{status:'inconsistent',cycle:[{id:'loop',from:'a',to:'a',bound:-1,side:'upper'}]});
 assert.deepEqual(results[8],{status:'error',code:'invalid_input',message:'unknown timepoint: x'});
 assert.deepEqual(results[2],results[9]);
}
function verifyWideColumns(invoke) {
 const timepoints=Array.from({length:64},(_,i)=>'v'+i);
 const parent=i=>Math.floor((i-1)/2);
 const constraints=timepoints.slice(1).map((to,i)=>({id:'e'+i,from:timepoints[parent(i+1)],to,upper:-1}));
 const pairs=Array.from({length:256},(_,i)=>[i%64,(i*23+Math.floor(i/64)*17)%64]);
 pairs.splice(0,3,[0,63],[63,0],[1,2]);
 const queries=pairs.map(([a,b])=>({from:timepoints[a],to:timepoints[b]}));
 const steps=64**3+3*constraints.length;
 const request={timepoints,constraints,queries,max_steps:steps};
 const input=JSON.stringify([request,{...request,max_steps:steps-1},request]);
 const out=invoke(['--batch','-'],input);
 assert.equal(out.status,0,out.stderr);
 const [first,short,again]=JSON.parse(out.stdout);
 assert.equal(first.status,'feasible');
 validate(request,first);
 const hops=(ancestor,descendant)=>{
   for(let count=0;descendant>=0;count++,descendant=parent(descendant)){
     if(descendant===ancestor) return count;
   }
   return null;
 };
 const expected=pairs.map(([a,b],i)=>{
   const forward=hops(a,b), reverse=hops(b,a);
   return {...queries[i],lower:reverse,upper:forward===null ? null : forward===0 ? 0 : -forward};
 });
 assert.deepEqual(first.bounds,expected);
 assert.deepEqual(short,{status:'error',code:'limit_exceeded',message:'work budget exhausted; no feasibility conclusion'});
 assert.deepEqual(again,first);
}
function signedClosureCase() {
 const size = 64;
 const timepoints = Array.from({length: size}, (_, i) => 'p' + i);
 const potential = timepoints.map((_, i) => (i * 323917) % 800000);
 const adjacency = timepoints.map(() => []);
 const constraints = timepoints.flatMap((from, i) => [1, 3, 11, 19].map((jump, k) => {
   const j = (i + jump) % size;
   const forward = (i * 8131 + jump * 931) % 150000;
   const reverse = (j * 8719 + jump * 811) % 150000;
   adjacency[i].push([j, forward]);
   if (k % 2 === 0) adjacency[j].push([i, reverse]);
   const offset = potential[j] - potential[i];
   return {id: 'e' + i + '-' + jump, from, to: timepoints[j], upper: offset + forward,
     lower: k % 2 === 0 ? offset - reverse : null};
 }));
 // Dijkstra on nonnegative weights, before adding endpoint potential differences.
 const distance = timepoints.map((_, source) => {
   const cost = Array(size).fill(Infinity);
   const visited = Array(size).fill(false);
   cost[source] = 0;
   for (let step = 0; step < size; step++) {
     let best = -1;
     for (let i = 0; i < size; i++) {
       if (!visited[i] && (best === -1 || cost[i] < cost[best])) best = i;
     }
     visited[best] = true;
     for (const [target, weight] of adjacency[best]) {
       cost[target] = Math.min(cost[target], cost[best] + weight);
     }
   }
   return cost;
 });
 const queries = Array.from({length: 256}, (_, k) => {
   const a = k % size;
   const b = (a * 11 + Math.floor(k / size) * 13) % size;
   return {a, b, from: timepoints[a], to: timepoints[b]};
 });
 return {
   request: {timepoints, constraints, queries: queries.map(({from,to}) => ({from,to}))},
   bounds: queries.map(({a,b,from,to}) => ({
     from, to, lower: potential[b] - potential[a] - distance[b][a],
     upper: potential[b] - potential[a] + distance[a][b],
   })),
 };
}
const signedClosure = signedClosureCase();
function validate(request,result){
 const arcs=request.constraints.flatMap(e=>[...(e.upper==null?[]:[{id:e.id,from:e.from,to:e.to,bound:e.upper,side:'upper'}]),...(e.lower==null?[]:[{id:e.id,from:e.to,to:e.from,bound:-e.lower,side:'lower'}])]);
 if(result.status==='feasible'){assert.deepEqual(Object.keys(result.assignment).sort(),[...request.timepoints].sort());assert.equal(result.assignment[request.timepoints[0]],0);assert(arcs.every(e=>result.assignment[e.to]-result.assignment[e.from]<=e.bound));}
 else {assert.equal(result.status,'inconsistent');assert(result.cycle.length>0&&result.cycle.length<=request.timepoints.length);assert(result.cycle.every((e,i)=>arcs.some(a=>JSON.stringify(a)===JSON.stringify(e))&&e.to===result.cycle[(i+1)%result.cycle.length].from));assert(result.cycle.reduce((s,e)=>s+e.bound,0)<0);}
}
for(const mode of ['debug','release']){
 const flag=mode==='release'?['--release']:[];
 assert.equal(run(moon,['run','examples/library','--target','js',...flag]).trim(),'PASS public API: feasible bounds and checked conflict');
 assert.equal(run(moon,['run','examples/planning','--target','js',...flag]).trim(),'PASS planning API: backtracking, independent witness, unschedulable and budget recovery');
 const units=run(moon,['test','--target','js','--deny-warn',...flag]);process.stdout.write(units);
 run(moon,['build','cmd/main','--target','js','--deny-warn',...flag]);
 const cli=path.join(root,`_build/js/${mode}/build/cmd/main/main.js`);
 const invoke=(args,input)=>spawnSync(process.execPath,['--max-old-space-size=192',cli,...args],{input,encoding:'utf8',timeout:15000,maxBuffer:4*1024*1024});
 const batch=(requests)=>{
   const input=JSON.stringify(requests);
   const r=invoke(['--batch','-'],input);
   assert.equal(r.error,undefined);
   assert.equal(r.status,0,r.stderr);
   const results=JSON.parse(r.stdout);
   if(baselineCli){
     const previous=run(process.execPath,[baselineCli,'--batch','-'],{input});
     assert.deepEqual(results,JSON.parse(previous),`${mode} numeric results differ from baseline`);
   }
   return results;
 };
 for(let start=0;start<cases.length;start+=64){const chunk=cases.slice(start,start+64);const actual=batch(chunk.map(c=>c.request));assert.equal(actual.length,chunk.length);actual.forEach((result,i)=>{const c=chunk[i];assert.equal(result.status,c.feasible?'feasible':'inconsistent',`network ${start+i}`);validate(c.request,result);if(c.feasible)assert.deepEqual(result.bounds,c.bounds,`bounds ${start+i}`);});}
 const [signed] = batch([signedClosure.request]);
 assert.equal(signed.status, 'feasible');
 validate(signedClosure.request, signed);
 assert.deepEqual(signed.bounds, signedClosure.bounds, `${mode} signed 64-point closure`);
 console.log(`PASS ${mode}: 4096 exhaustive networks, assignments, bounds and conflict certificates`);
 const good={timepoints:['zero'],constraints:[]};
 const invalid=[null,{}, {...good,typo:1},{...good,timepoints:['a','a']},{...good,timepoints:['a b']},{...good,constraints:[{id:'c',from:'zero',to:'x',upper:1}]},{...good,constraints:[{id:'c',from:'zero',to:'zero',upper:1.5}]},{...good,constraints:[{id:'c',from:'zero',to:'zero',upper:1e100}]},{...good,constraints:[{id:'c',from:'zero',to:'zero'}]},{...good,max_steps:0},{...good,max_steps:1.5},{...good,queries:[{from:'zero',to:'missing'}]},{...good,timepoints:Array.from({length:65},(_,i)=>`v${i}`)},{...good,constraints:Array.from({length:513},(_,i)=>({id:`c${i}`,from:'zero',to:'zero',upper:0}))},{...good,timepoints:['a','b'],max_steps:1}];
 for(const bad of invalid){const r=batch([good,bad,good]);assert.equal(r[0].status,'feasible');assert.equal(r[1].status,'error');assert.equal(r[2].status,'feasible');}
 const transport=['{"timepoints":["a"],"timepoints":["b"],"constraints":[]}', '[', '['.repeat(17)+'0'+']'.repeat(17), ' '.repeat(1048577),'"'+'x'.repeat(257)+'"',JSON.stringify(Array(65).fill(good))];
 for(const input of transport){const r=invoke(['--batch','-'],input);assert.equal(r.status,2);assert.equal(r.stdout,'');assert(r.stderr.length>0);}
 const utf=invoke(['-'],Buffer.from([0xff]));assert.equal(utf.status,2);assert.equal(utf.stdout,'');
 verifyIntegerSpellings(invoke);
 verifyNumericEncoding(invoke);
 verifyQueryErrorOrder(invoke);
 verifyJsonScanBounds(invoke);
 verifyClosureBudgetOrder(invoke);
 verifyWideColumns(invoke);
 const bom=invoke(['-'],'\ufeff'+JSON.stringify(good));assert.equal(bom.status,0,bom.stderr);
 for(const args of [[],['--unknown'],['x','y'],['missing-file.json']]){const r=invoke(args,'');assert.equal(r.status,2);assert.equal(r.stdout,'');}
 assert.equal(invoke(['--version'],'').stdout.trim(),'0.2.19');
 const fd=fs.openSync(path.join(root,'moon.mod'),'r');try{const r=spawnSync(process.execPath,[cli,'--version'],{stdio:['ignore',fd,'pipe'],encoding:'utf8',timeout:15000});assert.equal(r.status,2);}finally{fs.closeSync(fd);}
 const scenarios=['deployment','delivery','conflict'];
 for(const name of scenarios){const request=JSON.parse(fs.readFileSync(`examples/${name}.json`,'utf8'));const r=invoke([`examples/${name}.json`],'');assert.equal(r.status,0,r.stderr);const result=JSON.parse(r.stdout);validate(request,result);assert.equal(result.status,name==='conflict'?'inconsistent':'feasible');if(name==='deployment')assert.deepEqual(result.bounds,[{from:'zero',to:'release',lower:15,upper:35}]);if(name==='delivery')assert.deepEqual(result.bounds,[{from:'pickup',to:'arrival',lower:20,upper:40}]);}
 console.log(`PASS ${mode}: malformed input, batch isolation, process I/O and three scenarios`);
 reports.push({mode,unitTests:units.trim(),exhaustiveNetworks:4096,signedClosureBounds:256,...(baselineCli ? {numericBaselineCompared:true}:{}),invalidBatchItems:invalid.length,numericEncodingCompared:true,queryErrorOrderCompared:true,jsonScanBoundsCompared:true,closureBudgetOrderCompared:true,wideColumnsCompared:true,transportRejects:transport.length+1,scenarios});
}
process.stdout.write(run(process.execPath,['scripts/verify-planning.mjs',...process.argv.slice(2)]));
fs.writeFileSync(summary,JSON.stringify({status:'passed',recordedAt:new Date().toISOString(),node:process.version,reports},null,2)+'\n');
