# `scalac` exec group

Every rule that runs the Scalac compile action directly declares a Bazel
[`exec_group`][exec_groups] named `scalac`. Users can set execution properties
for the Scalac action independently of the target's other actions via
`exec_properties = {"scalac.<key>": "<value>"}` on the target.

Rules that declare the `scalac` exec group (target-level `exec_properties`
supported):

- `scala_library`
- `scala_macro_library`
- `scala_library_for_plugin_bootstrapping`
- `scala_binary`
- `scala_test`
- `scala_junit_test`
- `scala_repl` (only meaningful with `srcs`; most REPL targets have none)

`scala_doc` runs `scaladoc`, not `scalac`, and is not covered.

## Aspect-based rules

`scala_proto_library` and `scrooge_scala_library` run their Scalac compile
inside a Bazel aspect. Bazel does *not* propagate target-level
`exec_properties` to actions created by attached aspects, so setting
`exec_properties = {"scalac.<key>": ...}` on those targets does not work
(and fails at analysis time — the top-level rule intentionally does not
declare the exec group, to surface the limitation rather than silently
ignore the property). To configure the Scalac action for these rules, use
platform-level `exec_properties` on the [`platform`][platform_exec_properties]
that owns the aspect action.

## Example

Give the Scalac action of a specific `scala_library` more CPUs on a remote
executor:

```py
scala_library(
    name = "big_lib",
    srcs = glob(["*.scala"]),
    exec_properties = {"scalac.cpu": "4"},
)
```

The `scalac.` prefix routes the property to the `scalac` exec group; only
the Scalac action sees it. Other actions produced by the same target (for
example, ijar) are unaffected.

`exec_properties` values are always strings per Bazel's schema — write
`"4"`, not `4`.

The specific key names after `scalac.` depend on the remote executor in use
(`cpu`, `container-image`, etc.) — consult your remote executor's docs.

[exec_groups]: https://bazel.build/extending/exec-groups
[platform_exec_properties]: https://bazel.build/reference/be/platforms-and-toolchains#platform.exec_properties
