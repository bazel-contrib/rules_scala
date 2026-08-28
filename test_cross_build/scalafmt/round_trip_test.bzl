load("@rules_shell//shell:sh_test.bzl", "sh_test")

def scalafmt_round_trip_test(name, rule_type, filename):
    """Asserts formatted-$rule_type is already formatted, unformatted-$rule_type
    is not, and running the formatter over unformatted-$filename.scala produces
    formatted-$filename.scala.

    Reads the phase's own `manifest.txt`/`.fmt.output` action outputs directly,
    resolved relative to this test's own runfiles root, rather than running
    the `.format-test`/`.format` scripts the fixtures also produce: those
    scripts locate their compiled outputs by walking their own path up to the
    bazel-out "bin" directory, which only holds under the wrapping test's own
    build configuration -- every fixture here pins its own `scala_version`
    (a different configuration from this test's).

    Args:
        name: test target name.
        rule_type: the `formatted-$rule_type`/`unformatted-$rule_type` targets'
            common suffix (e.g. `"binary2"`, `"test3"`).
        filename: the `formatted-$filename.scala`/`unformatted-$filename.scala`
            source files' common suffix.
    """
    package = native.package_name()
    unformatted_src = "unformatted/unformatted-%s.scala" % filename
    formatted_manifest = "%s/format/formatted-%s/manifest.txt" % (package, rule_type)
    unformatted_manifest = "%s/format/unformatted-%s/manifest.txt" % (package, rule_type)
    sh_test(
        name = name,
        srcs = ["round_trip_test.sh"],
        args = [
            formatted_manifest,
            unformatted_manifest,
            package + "/" + unformatted_src,
            "%s/formatted/formatted-%s.scala" % (package, filename),
        ],
        data = [
            ":formatted-%s" % rule_type,
            ":unformatted-%s" % rule_type,
        ],
    )
