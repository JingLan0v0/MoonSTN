# Sources, license and AI assistance

MoonSTN's model, solver, JSON schema adapter, certificate checks and independent
enumeration oracle were written for this project in MoonBit/JavaScript. No source
from another STN solver, MoonAllen, MoonPlan or MoonPath was copied.

Theory references (algorithms and mathematical model, not copied source):
- Dechter, Meiri and Pearl, Temporal Constraint Networks (1991),
  https://doi.org/10.1016/0004-3702(91)90006-6 .
- Hunsberger, Algorithms for a Temporal Decoupling Problem in Multi-Agent Planning,
  https://cdn.aaai.org/AAAI/2002/AAAI02-071.pdf .
- Standard Bellman-Ford negative-cycle detection and Floyd-Warshall closure.

The Node file/stdin/output adapter in cmd/main/host.mbt and the Windows pinned
compiler installer were adapted from JingLan0v0/moonbit-jmespath (Apache-2.0,
commit d32c4c120bba79541ea204a9a86b23c28de67993). The adapter's byte limit and program
name were changed; the installer uses this project's separate pinned toolchain.
These are shared engineering infrastructure, not the new algorithmic contribution.
The Apache-2.0 license text is retained. MoonBit core is the only library dependency;
its distribution remains in the external toolchain, not copied into this project.

The test vectors and oracle are locally generated; no third-party test suite is
redistributed and there is no claim of official STN conformance certification.
AI assisted scope review, implementation, testing and documentation. The participant
must understand and be able to explain the delivered code and claims.
