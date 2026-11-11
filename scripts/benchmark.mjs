import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {performance} from 'node:perf_hooks';
// Run after a release build; optionally compare against a saved baseline CLI.
const root=path.resolve(import.meta.dirname,'..');
const current=path.join(root,'_build/js/release/build/cmd/main/main.js');
const baseline=process.argv[2] && path.resolve(process.argv[2]);
const names=Array.from({length:64},(_,i)=>`v${i}`);
const graphs={
  disconnected:[],
  chain:names.slice(1).map((to,i)=>({id:`e${i}`,from:names[i],to,upper:1})),
  connected:names.flatMap((from,i)=>Array.from({length:8},(_,j)=>({id:`e${i}_${j}`,from,to:names[(i+j+1)%64],upper:1})))
};
function invoke(cli,requests){
 const start=performance.now();
 const r=spawnSync(process.execPath,[cli,'--batch','-'],{input:JSON.stringify(requests),encoding:'utf8',timeout:30000,maxBuffer:4*1024*1024});
 assert.equal(r.error,undefined);assert.equal(r.status,0,r.stderr);
 return {ms:performance.now()-start,result:JSON.parse(r.stdout)};
}
const rows=[];
for(const [name,constraints] of Object.entries(graphs)){
 const request={timepoints:names,constraints,queries:[{from:'v0',to:'v63'},{from:'v63',to:'v0'}]};
 const batch=Array(8).fill(request);
 const expected=invoke(baseline||current,batch).result;
 assert(expected.every(r=>r.status==='feasible'));
 const times={current:[],baseline:[]};
 // Alternate order to limit systematic warm-up/order bias; include process startup.
 for(let i=0;i<11;i++){
   const order=i%2 ? ['current','baseline'] : ['baseline','current'];
   for(const label of order){
     const cli=label==='baseline'?baseline:current;if(!cli)continue;
     const r=invoke(cli,batch);assert.deepEqual(r.result,expected);
     if(i>=2)times[label].push(r.ms);
   }
 }
 const median=xs=>xs.sort((a,b)=>a-b)[Math.floor(xs.length/2)];
 const row={name,requestsPerSample:8,currentMedianMs:median(times.current)};
 if(baseline){row.baselineMedianMs=median(times.baseline);row.speedup=row.baselineMedianMs/row.currentMedianMs;
   // Differential low-budget checks must preserve errors as well as successes.
   for(const max_steps of [1,63,64,65,4095,4096,262143,262144,263168,2000000]){
     assert.deepEqual(invoke(current,[{...request,max_steps}]).result,invoke(baseline,[{...request,max_steps}]).result);
   }
 }
 rows.push(row);
}
const report={recordedAt:new Date().toISOString(),node:process.version,samples:9,includesProcessStartup:true,baseline:baseline||null,rows};
fs.writeFileSync(path.join(root,'_build/benchmark-summary.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
