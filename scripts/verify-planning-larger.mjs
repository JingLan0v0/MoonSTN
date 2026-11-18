import assert from 'node:assert/strict';

const kinds = ['FS', 'SS', 'FF', 'SF'];
const endpoints = {FS: [1, 0], SS: [0, 0], FF: [1, 1], SF: [0, 1]};
const budgets = {max_nodes: 10000, max_work: 100000000};
export const planningSeed = 169603;
let seed = planningSeed;

function randomBelow(limit) {
  seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
  return Math.floor(seed / 4294967296 * limit);
}

function shuffle(items) {
  for (let i = items.length - 1; i > 0; i--) {
    const j = randomBelow(i + 1);
    [items[i], items[j]] = [items[j], items[i]];
  }
  return items;
}

// Enumerate concrete intervals, filtering remaining domains after each placement.
// The search operates on original task and dependency rules.
function feasible(req) {
  const index = new Map(req.tasks.map((task, i) => [task.id, i]));
  const rules = req.tasks.map(() => req.tasks.map(() => []));
  for (const {before, after, kind, min_lag, max_lag} of req.dependencies) {
    const a = index.get(before);
    const b = index.get(after);
    const [from, to] = endpoints[kind];
    assert.notEqual(a, b, 'Generated fixtures use distinct dependency endpoints');
    const accepts = (first, second) => {
      const lag = second[to] - first[from];
      return lag >= min_lag && (max_lag == null || lag <= max_lag);
    };
    rules[a][b].push(accepts);
    rules[b][a].push((second, first) => accepts(first, second));
  }
  const tasks = req.tasks;
  for (let a = 0; a < tasks.length; a++) {
    if (tasks[a].resource == null) continue;
    for (let b = a + 1; b < tasks.length; b++) {
      if (tasks[a].resource !== tasks[b].resource) continue;
      const disjoint = ([startA, endA], [startB, endB]) => endA <= startB || endB <= startA;
      rules[a][b].push(disjoint);
      rules[b][a].push(disjoint);
    }
  }
  const initial = tasks.map((task, i) => {
    const choices = [];
    for (let start = task.release; start + task.min_duration <= task.deadline; start++) {
      for (let d = task.min_duration; d <= task.max_duration && start + d <= task.deadline; d++) {
        choices.push([start, start + d]);
      }
    }
    return {i, choices};
  });
  let visits = 0;
  function visit(domains) {
    assert(++visits <= 100000, 'Enumeration exceeded the fixture work bound');
    if (domains.length === 0) return true;
    const [next, ...remaining] = domains.toSorted((a, b) => a.choices.length - b.choices.length);
    return next.choices.some(interval => visit(remaining.map(({i, choices}) => ({
      i,
      choices: choices.filter(choice => rules[next.i][i].every(rule => rule(interval, choice))),
    }))));
  }
  return visit(initial);
}

function dependency(before, after, kind, lo, hi) {
  return {before, after, kind, min_lag: lo, max_lag: hi};
}

function seededCase(i) {
  const offset = i % 2 === 0 ? 0 : 999980;
  const cursor = Array(3).fill(offset + 1);
  const placements = Array.from({length: 8 + i % 5}, (_, id) => {
    const resource = id % 3;
    const duration = 1 + randomBelow(2);
    const start = cursor[resource];
    const end = start + duration;
    cursor[resource] = end;
    return {
      slot: [start, end],
      task: {id: 't' + id, min_duration: Math.max(1, duration - randomBelow(2)),
        max_duration: duration + randomBelow(2), release: start - randomBelow(2),
        deadline: end + randomBelow(3), resource: 'r' + resource},
    };
  });
  const dependencies = placements.map(({task, slot}, a) => {
    const b = (a + 1 + randomBelow(2)) % placements.length;
    const kind = kinds[(i + a) % kinds.length];
    const [from, to] = endpoints[kind];
    const lag = placements[b].slot[to] - slot[from];
    // Some dependencies have only a lower bound. Others constrain both endpoints.
    return dependency(task.id, placements[b].task.id, kind, lag - randomBelow(2),
      a % 5 === 0 ? null : lag + randomBelow(2));
  });
  const req = {...budgets, tasks: shuffle(placements.map(p => p.task)), dependencies};
  const tightened = {...req, dependencies: dependencies.map(d => ({...d}))};
  const changed = tightened.dependencies[randomBelow(dependencies.length)];
  // Shift the lag interval as a unit, leaving the dependency itself well formed.
  changed.min_lag += 2;
  if (changed.max_lag != null) changed.max_lag += 2;
  return [
    {name: 'seeded-' + i, req, expected: true},
    {name: 'shifted-lag-' + i, req: tightened},
  ];
}

function capacityCases() {
  const tasks = [];
  const dependencies = [];
  const name = (resource, phase) => 'r' + resource + 't' + phase;
  for (let resource = 0; resource < 4; resource++) {
    for (let phase = 0; phase < 6; phase++) {
      const pinned = phase < 2;
      tasks.push({id: name(resource, phase), min_duration: 1, max_duration: 1,
        release: pinned ? phase : 2,
        deadline: pinned ? phase + 1 : 6,
        resource: 'r' + resource});
      if (resource > 0) {
        const kind = kinds[(resource + phase) % kinds.length];
        const [from, to] = endpoints[kind];
        dependencies.push(dependency(name(0, phase), name(resource, phase), kind, to - from, to - from));
      }
    }
  }
  // Keep the 18 synchronizing links and fill the 64-dependency cap with
  // cross-resource lag bounds that cover every interval in these windows.
  for (let a = 0; a < 6 && dependencies.length < 64; a++) {
    for (let b = 0; b < 18 && dependencies.length < 64; b++) {
      dependencies.push(dependency(name(0, a), tasks[6 + b].id, kinds[(a + b) % kinds.length], -6, 6));
    }
  }
  const req = {...budgets, tasks: shuffle(tasks), dependencies};
  // Four unit tasks on r0 now share only three slots. Synchronizing links
  // remain satisfiable if simultaneous use of r0 is allowed.
  const overloaded = req.tasks.map(task => task.resource === 'r0' && task.release === 2
    ? {...task, deadline: 5} : task);
  return [
    {name: 'capacity-exact', req, expected: true},
    {name: 'capacity-overload', req: {...req, tasks: overloaded}, expected: false},
  ];
}

export function largerPlanningCases() {
  seed = planningSeed;
  const cases = Array.from({length: 48}, (_, i) => seededCase(i)).flat();
  cases.push(...capacityCases());
  return cases.map(({name, req, expected}) => {
    const canSchedule = feasible(req);
    if (expected !== undefined) assert.equal(canSchedule, expected, name);
    return {name, req, feasible: canSchedule};
  });
}
