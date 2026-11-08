# scala_doc

```py
scala_doc(
    name,
    deps,
)
```

`scala_doc` generates [Scaladoc](https://docs.scala-lang.org/style/scaladoc.html) for sources
for targets, including sources from upstream deps. Readily hostable HTML is written to a `name.html` output folder.

With Scala 3, `scala_doc` runs the Scala 3 Scaladoc. It reads the TASTy files
of the compiled deps, so `scalacopts` gives Scaladoc options, for example
`-source-links`. Set [`scala_version`](cross-compilation.md) on `scala_doc` to
the version of the deps. Scala 3 `scala_doc` writes API pages for the Scala 3
deps only. Java deps and Scala 2 deps stay on the classpath, so Scaladoc can
read the types they define. Static site support (`-siteroot`) can come in a
later change.

Scala 3 `scala_doc` needs the Scaladoc jars. To download them and add them to
the default Scala toolchains, use `scala_deps.scaladoc()` in `MODULE.bazel` or
`scala_toolchains(scaladoc = True)` in `WORKSPACE`.

Scaladoc can be somewhat slow to build. In that case, you can tell Bazel to build this target manually,
i.e. only when named explicitly and not through wildcards: `tags = ["manual"]`.

## Example

```py
scala_doc(
    name = "scala_docs",
    tags = ["manual"],
    deps = [
        ":target1",
        ":target2",
        ":anothertarget",
    ],
    scalacopts = [
        "-Ypartial-unification",
        "-Ywarn-unused-import",
    ],
)

# Use pkg_tar to tarball up
# https://docs.bazel.build/versions/master/be/pkg.html#pkg_tar
pkg_tar(
    name = "scala_docs_archive",
    srcs = [":scala_docs"],
    extension = "tar.gz",
)
```

## Attributes

| Attribute name        | Description                                           |
| --------------------- | ----------------------------------------------------- |
| name                  | `Name, required`<br/>A unique name for this target. |
| deps                  | `List of labels, optional`<br/>Labels for which you want to create scaladoc. |
| scalacopts            | `List of strings, optional`<br/>Extra options for Scaladoc. With Scala 2, Scaladoc also reads scalac options. |
