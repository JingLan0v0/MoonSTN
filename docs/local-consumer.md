# Local dependency smoke check

Before registry publication, use MoonBit workspaces rather than `moon add`:

1. Create a separate consumer module with `moon.mod`:

```moonbit
name = "local/stn_consumer"
version = "0.0.0"
preferred_target = "js"
import { "JingLan0v0/stn@0.1.0" }
```

2. Its `moon.pkg` imports `JingLan0v0/stn` as `stn` and declares an executable.
   Copy `examples/library/main.mbt` as the public API smoke example.
3. From the consumer directory run `moon work init . /absolute/path/to/moonbit-stn`.
4. Run `moon run . --target js --deny-warn`, then add `--release` and repeat.

This is a local workspace dependency check, not a Mooncakes download. The current
compiler does not support legacy local `deps.path` manifests. The test consumer
is ignored in `_build/consumer`; its workspace may contain absolute local paths
and must not be committed or included in the delivery archive.
