# scala_repl

```py
scala_repl(
    name,
    deps,
    scalacopts,
    jvm_flags,
    scalac_jvm_flags,
    javac_jvm_flags,
    unused_dependency_checker_mode,
    scala_version
)
```

`scala_repl` allows you to add library dependencies (but not currently `scala_binary` targets)
and then generate a _script_ which starts a REPL.

Since `bazel run` closes stdin, it cannot be used to start a REPL.
Instead, use `bazel build` to build the script, then run that script as normal to start a REPL session.

An example in this repo:

```txt
bazel build test:HelloLibRepl
bazel-bin/test/HelloLibRepl
```

`scala_version` pins the target to a specific Scala version, overriding the
default toolchain's version:

```py
scala_repl(
    name = "Scala3Repl",
    scala_version = "3.9.0",
)
```
