# Ecosystem review — 2026-11-10

Registry inventory: https://mooncakes.io/api/v0/modules . Searched names,
descriptions and keywords for STN, simple temporal networks, difference constraints,
constraint/scheduling and graph algorithms; additionally searched public GitHub/web.
No directly named STN/difference-constraint module was returned by this scan.
This is a scoped search result, not proof that no equivalent code exists anywhere.

| Existing project | Actual boundary reviewed | MoonSTN difference |
|---|---|---|
| [MoonAllen](https://github.com/yujieMamba/moonallen) | Qualitative Allen interval relations, propagation/search, ordinal witnesses | Numeric point differences, concrete duration bounds and tight ranges; no qualitative relation disjunctions |
| [MoonPlan](https://github.com/cn-xjr/MoonPlan) | Finite-domain constraints and personnel scheduling with search/optimization | Specialized polynomial difference-constraint analysis; no enumeration of a time domain or staffing objective |
| [MoonPath](https://github.com/wzx2007/moonpath) | General graphs, shortest paths, Bellman-Ford helpers | User-facing interval rules, upper/lower provenance, independently checkable conflict/assignment evidence and bounded JSON batch contract |

README/API scope of the three repositories was read during this review. MoonSTN
uses standard graph algorithms, not a claim of a new algorithm. It is not a fork
of those implementations. A separate focused package avoids adding scheduling
policy, result/evidence contracts and exchange validation to a generic graph API.
It could later be used alongside graph, planning or qualitative interval tools.

Earlier candidates were rejected after checking registry metadata: URI templates,
robots.txt and relational normalization already have direct dedicated modules
(e.g. cjyhjy/uri_template, liuhang0001/moon-robots, LuoYunxin1/moonnormal).
The proposal therefore must not describe MoonSTN as a renamed version of those
candidates or as a split of MoonJMES. Repeat the scan before actual submission.
