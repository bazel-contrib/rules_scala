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
sources only. Scaladoc reads the types of Java sources, Java deps and Scala 2
deps from the classpath.

Scala 3 `scala_doc` can also add a
[static site](https://docs.scala-lang.org/scala3/guides/scaladoc/static-site.html).
Put the site files, for example `_docs/`, `_blog/` and `sidebar.yml`, in
`site_srcs`, and set `site_root` to their root directory. Scaladoc writes the
pages of `_docs/` to `docs/` in the output.

```py
scala_doc(
    name = "scala_docs",
    scala_version = "3.9.0",
    site_root = "site",
    site_srcs = glob(["site/**"]),
    deps = [":target1"],
)
```

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
| site_srcs             | `List of labels, optional`<br/>Static site files for Scala 3 Scaladoc. All files must be under `site_root`. Scala 2 `scala_doc` fails if this is not empty. |
| site_root             | `String, optional`<br/>The root directory of `site_srcs`, relative to the package of this target. The default is the package directory. |
