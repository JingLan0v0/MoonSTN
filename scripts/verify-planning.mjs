import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {largerPlanningCases, planningSeed} from './verify-planning-larger.mjs';
const root=path.resolve(import.meta.dirname,'..');process.chdir(root);
const baseline=process.argv[2] && path.resolve(process.argv[2]);
const receipt=path.join(root,'_build/planning-verification.json');fs.rmSync(receipt,{force:true});
function valid(req,ss){
 if(ss.length!==req.tasks.length||new Set(ss.map(s=>s.id)).size!==ss.length)return false;
 const m=Object.fromEntries(ss.map(s=>[s.id,s]));
 for(const t of req.tasks){const s=m[t.id];if(!s||!Number.isSafeInteger(s.start)||!Number.isSafeInteger(s.finish)||s.start<t.release||s.finish>t.deadline||s.finish-s.start<t.min_duration||s.finish-s.start>t.max_duration)return false;}
 for(const d of req.dependencies||[]){const a=m[d.before],b=m[d.after],gap=b[d.kind[1]==='F'?'finish':'start']-a[d.kind[0]==='F'?'finish':'start'];if(gap<d.min_lag||(d.max_lag!=null&&gap>d.max_lag))return false;}
 for(let i=0;i<req.tasks.length;i++)for(let j=i+1;j<req.tasks.length;j++){const a=req.tasks[i],b=req.tasks[j];if(a.resource!=null&&a.resource===b.resource&&m[a.id].start<m[b.id].finish&&m[b.id].start<m[a.id].finish)return false;}
 return true;
}
function exists(req){const ss=[];function visit(i){if(i===req.tasks.length)return valid(req,ss);const t=req.tasks[i];for(let start=t.release;start<=t.deadline;start++)for(let duration=t.min_duration;duration<=t.max_duration&&start+duration<=t.deadline;duration++){ss.push({id:t.id,start,finish:start+duration});if(visit(i+1))return true;ss.pop();}return false;}return visit(0);}
function verifyPlanningFields(invoke) {
 const a = {deadline:1, release:0, max_duration:1, min_duration:1, id:'a'};
 const b = {...a, id:'b', deadline:2};
 const edge = {min_lag:0, kind:'FS', after:'b', before:'a'};
 const good = {tasks:[a,b], dependencies:[edge]};
 const nulls = {tasks:[{...a,resource:null},{...b,resource:null}], dependencies:[{max_lag:null,...edge}]};
 const assigned = {tasks:[{resource:'r',...a},{...b,resource:'r'}], dependencies:[{max_lag:0,...edge}]};
 const tasks = rule => ({...good, tasks:[a,rule]});
 const dependencies = rule => ({...good, dependencies:[rule]});
 const errors = [
   [tasks({...b, id:undefined, resource:false, zeta:0, alpha:0}), 'unknown field: zeta'],
   [tasks({...b, id:undefined, resource:false}), 'resource must be a string'],
   [tasks({...b, id:undefined, min_duration:false, resource:null}), 'missing field: id'],
   [tasks({...b, id:false, min_duration:undefined}), 'id must be a string'],
   [tasks({...b, min_duration:undefined, max_duration:false}), 'missing field: min_duration'],
   [dependencies({...edge, before:undefined, max_lag:false, zeta:0, alpha:0}), 'unknown field: zeta'],
   [dependencies({...edge, before:undefined, max_lag:'NUMBER'}), 'expected bounded integer'],
   [dependencies({...edge, before:undefined, max_lag:null, after:false}), 'missing field: before'],
   [dependencies({...edge, before:false, after:undefined}), 'before must be a string'],
   [dependencies({...edge, kind:undefined, min_lag:false}), 'missing field: kind'],
   [{...dependencies({...edge,zeta:0}),tasks:[{...a,id:'invalid name'},b]}, 'unknown field: zeta'],
 ];
 const inputs = [good, nulls, assigned, ...errors.map(([request]) => request), good];
 const raw = JSON.stringify(inputs).replace('"NUMBER"', '1.00000000000000001');
 const out = invoke(['--plan-batch','-'], raw);
 assert.ifError(out.error);
 assert.equal(out.status, 0, out.stderr);
 const results = JSON.parse(out.stdout);
 assert.equal(results.length, inputs.length);
 const expected = [{id:'a',start:0,finish:1},{id:'b',start:1,finish:2}];
 for (const [i, result] of results.slice(0, 3).entries()) {
   assert.equal(result.status, 'planned');
   assert.deepEqual(result.schedule, expected);
   assert(valid(inputs[i], result.schedule));
 }
 assert.deepEqual(results[1], results[0]);
 assert.deepEqual(results.at(-1), results[0]);
 assert.deepEqual(results.slice(3, -1), errors.map(([,message]) =>
   ({status:'error', code:'invalid_input', message})));
 return out.stdout;
}
const task=(id,d,release,deadline,resource)=>({id,min_duration:d,max_duration:d+1,release,deadline,resource});
const cases=[];
for(const da of [1,2])for(const db of [1,2])for(const ra of [0,1])for(const rb of [0,1])for(const endA of [2,3,4])for(const endB of [2,3,4])for(const shared of [false,true])for(const kind of [null,'FS','SS','FF','SF']){
 const req={tasks:[task('a',da,ra,endA,shared?'r':null),task('b',db,rb,endB,shared?'r':null)],dependencies:kind?[{before:'a',after:'b',kind,min_lag:0,max_lag:1}]:[]};cases.push({req,feasible:exists(req)});
}
let seed=7123;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return Math.floor(seed/4294967296*n);};
for(let i=0;i<256;i++){const tasks=Array.from({length:3},(_,j)=>task('t'+j,1+rand(2),rand(2),3+rand(3),rand(2)?'r':null));const dependencies=[];for(let j=0;j<3;j++){if(rand(2))dependencies.push({before:'t'+j,after:'t'+((j+1)%3),kind:['FS','SS','FF','SF'][rand(4)],min_lag:rand(3)-1,max_lag:2});}const req={tasks,dependencies};cases.push({req,feasible:exists(req)});}
const reports=[];
const larger = largerPlanningCases();
for(const mode of ['debug','release']){
 const cli=path.join(root,`_build/js/${mode}/build/cmd/main/main.js`);
 const invoke=(args,input)=>spawnSync(process.execPath,['--max-old-space-size=192',cli,...args],{input,encoding:'utf8',timeout:15000,maxBuffer:4*1024*1024});
 const fieldsOutput = verifyPlanningFields(invoke);
 if (baseline) {
   const previousInvoke = (args,input) => spawnSync(process.execPath,[baseline,...args],{input,encoding:'utf8',timeout:15000});
   assert.equal(verifyPlanningFields(previousInvoke), fieldsOutput, `${mode} planning field output differs from baseline`);
 }
 const batch=xs=>{
  const input=JSON.stringify(xs);
  const r=invoke(['--plan-batch','-'],input);assert.equal(r.error,undefined);assert.equal(r.status,0,r.stderr);
  const results=JSON.parse(r.stdout);
  if(baseline){
   const previous=spawnSync(process.execPath,[baseline,'--plan-batch','-'],{input,encoding:'utf8',timeout:15000,maxBuffer:4*1024*1024});
   assert.equal(previous.error,undefined);assert.equal(previous.status,0,previous.stderr);
   assert.deepEqual(results,JSON.parse(previous.stdout),`${mode} results differ from baseline`);
  }
  return results;
 };
 for(let i=0;i<cases.length;i+=64){const chunk=cases.slice(i,i+64),out=batch(chunk.map(x=>x.req));assert.equal(out.length,chunk.length);out.forEach((o,j)=>{assert.equal(o.status,chunk[j].feasible?'planned':'unschedulable',JSON.stringify(chunk[j].req));if(o.status==='planned')assert(valid(chunk[j].req,o.schedule));});}
 const largerResults = [];
 let budgetBoundaryCases = 0;
 for (let i = 0; i < larger.length; i += 32) {
   const chunk = larger.slice(i, i + 32);
   const results = batch(chunk.map(test => test.req));
   assert.equal(results.length, chunk.length);
   for (const [j, result] of results.entries()) {
     const {name, req, feasible} = chunk[j];
     const context = `${mode} ${name} seed=${planningSeed} ${JSON.stringify(req)}`;
     assert.equal(result.status, feasible ? 'planned' : 'unschedulable', context);
     if (feasible) assert(valid(req, result.schedule), context);
     largerResults.push({name, status: result.status, stats: result.stats});
     if (req.tasks.length === 24) {
       assert(result.stats.nodes > 1, context);
       const exact = {...req, max_nodes: result.stats.nodes, max_work: result.stats.charged_work};
       const [before, nodeLimit, workLimit, after] = batch([
         exact, {...exact, max_nodes: exact.max_nodes - 1},
         {...exact, max_work: exact.max_work - 1}, exact,
       ]);
       assert.deepEqual(before, result, context);
       assert.deepEqual(after, result, context);
       assert.equal(nodeLimit.status, 'error', context);
       assert.equal(nodeLimit.code, 'limit_exceeded', context);
       assert.match(nodeLimit.message, /node budget/, context);
       assert.equal(workLimit.status, 'error', context);
       assert.equal(workLimit.code, 'limit_exceeded', context);
       assert.match(workLimit.message, /work budget/, context);
       budgetBoundaryCases++;
     }
   }
 }
 const good={tasks:[task('a',1,0,3,null)]};
 const overlap={tasks:[task('a',2,0,4,'r'),task('b',2,0,4,'r')]};
 const bad=[null,{}, {...good,extra:1},{tasks:[]},{tasks:Array.from({length:25},(_,i)=>task('t'+i,1,0,4,null))},{...good,max_nodes:0},{...good,max_work:0},{...good,max_work:1},{...overlap,max_nodes:1},{tasks:[{...good.tasks[0],min_duration:0}]},{tasks:[{...good.tasks[0],max_duration:0}]},{tasks:[{...good.tasks[0],release:0.5}]},{...good,dependencies:[{before:'missing',after:'a',kind:'FS',min_lag:0}]},{...good,dependencies:[{before:'a',after:'a',kind:'XX',min_lag:0}]},{...good,dependencies:Array(65).fill({before:'a',after:'a',kind:'SS',min_lag:0})}];
 for(const b of bad){const out=batch([good,b,good]);assert.equal(out[0].status,'planned');assert.equal(out[1].status,'error');assert.deepEqual(out[0],out[2]);const r=invoke(['--plan','-'],JSON.stringify(b));assert.equal(r.status,2);assert.equal(r.stdout,'');}
 for(const text of ['[','{"tasks":[],"tasks":[]}','['.repeat(17)+'0'+']'.repeat(17),JSON.stringify(Array(65).fill(good))]){const r=invoke(['--plan-batch','-'],text);assert.equal(r.status,2);assert.equal(r.stdout,'');}
 assert.deepEqual(batch([]),[]);
 for(const name of ['release-plan','maintenance-plan','impossible-plan']){const req=JSON.parse(fs.readFileSync('examples/'+name+'.json','utf8'));const r=invoke(['--plan','examples/'+name+'.json']);assert.equal(r.status,0,r.stderr);const o=JSON.parse(r.stdout);assert.equal(o.status,name==='impossible-plan'?'unschedulable':'planned');if(o.status==='planned')assert(valid(req,o.schedule));if(name==='maintenance-plan')assert(o.stats.decisions>0&&o.stats.pruned>0);}
 reports.push({mode,exhaustiveTwoTaskCases:1440,seededThreeTaskCases:256,invalidBatchItems:bad.length,scenarios:3,
   largerPlanningCases: larger.length, budgetBoundaryCases, fieldOrderCompared:true, largerResults});
 console.log(`PASS ${mode}: ${cases.length + larger.length} independent planning cases, original-rule witness validation and planning I/O`);
}
fs.writeFileSync(receipt,JSON.stringify({recordedAt:new Date().toISOString(),status:'passed',planningSeed,...(baseline ? {baselineCompared:true}:{}),reports},null,2)+'\n');
