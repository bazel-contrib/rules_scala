# Publish your Scala Libraries to a Maven Repository

Use the `scala_export` macro. It is the Scala version of
[`java_export`](https://github.com/bazel-contrib/rules_jvm_external/blob/6.9/docs/api.md#java_export)
from `rules_jvm_external`, and it needs `rules_jvm_external` 6.9 or later.

```py
load("@rules_scala//scala:scala_export.bzl", "scala_export")

scala_export(
    name = "greeter",
    srcs = glob(["*.scala"]),
    maven_coordinates = "com.example:greeter_2.13:1.0.0",
    deps = [
        "@maven//:com_google_guava_guava",
    ],
)
```

`scala_export` takes the arguments of `scala_library`, and it makes:

- `greeter`: The jar to publish. Other targets can depend on it.
- `greeter-pom`: The `pom.xml` file.
- `greeter-javadoc`: The Scaladoc jar, which is published as the javadoc jar.
- `greeter.publish`: Publishes the jar, the pom, the sources jar and the
  javadoc jar.

`scala_export` selects the jar contents and the pom dependencies with the rules
of `java_export`. For example, a target of `maven_install` has a
`maven_coordinates` tag, so it goes into the pom. By default, the Scala standard
library also goes into the pom, and the `scala_library_maven_deps` argument
changes this. Each dependency in the pom must be in a Maven repository: publish
it too, or use one from Maven Central.

To publish, run the `.publish` target:

```sh
bazel run --define "maven_repo=file://$HOME/.m2/repository" //:greeter.publish
```

Set `maven_repo` to an `https` URL to publish to a remote repository, and set
`maven_user` and `maven_password` for it. Add `--define gpg_sign=true` to sign
the files with GPG.

See the docstring in
[`scala/scala_export.bzl`](../scala/scala_export.bzl) for all arguments, and
for the Scaladoc setup with Scala 3.
