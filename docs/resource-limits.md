# Resource and exchange contract

| Boundary | Limit / interpretation |
|---|---|
| Timepoints | 1..64, including first point used as origin |
| Constraints | 0..512, at most 1,024 directed edges |
| Names and IDs | 1..64 ASCII letters/digits/underscore/dot/hyphen; case sensitive |
| Input bound | Integer -1,000,000..1,000,000; missing/null means no bound |
| Work per solve | Default 2,000,000; accepted 1..10,000,000 |
| Queries per JSON request | 0..256 |
| Batch requests | 0..64; each has a fresh solve budget |
| CLI input | 1 MiB bytes, strict UTF-8, optional leading BOM |
| Library JSON text | 1 Mi UTF-16 units, nesting <=16 |
| JSON string source | At most 256 scanned characters, including closing quote |
| JSON outer scan | At most 200,000 non-whitespace characters outside strings |
| Proof coordinates | ±100,000,000,000, checked before arithmetic |
| Conflict certificate | 1..number of timepoints authentic edges |

The core JSON parser also enforces depth and rejects duplicate keys. Unknown
schema fields are errors, preventing misspelled bounds from silently disappearing.
A direct analyze(Json) call validates model shapes without recursively traversing
arbitrary unexpected objects. Data schema arrays and names are checked before
expensive solving. Model validation is bounded but is outside the logical step
counter. No mutable JSON trees are stored in the solver.

Int64 handles reasoning; JSON results are exact within binary64's integer range
under the model caps. Raising max_steps cannot raise structural/numeric caps.
Budget exhaustion is an error with no feasibility conclusion. A batch's total
work may reach 64 times its per-item budget; this is not a shared batch budget.

The verifier runs CLI subprocesses with 192 MiB old-space and a 15-second timeout.
Those are test safeguards, not library memory/time guarantees. The library has
no concurrency or cancellation service. Host applications control request rates,
workers and timeouts. Output failures may leave partial bytes.

Closure budgets count logical triples, including triples skipped for unreachable
rows. The fixed V^3 closure charge is reserved before traversal; insufficient
budgets fail before doing that work. This preserves the success/error threshold.
Faster traversal does not grant additional logical work at a given budget.
