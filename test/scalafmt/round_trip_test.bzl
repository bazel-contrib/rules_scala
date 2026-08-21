load("@rules_shell//shell:sh_test.bzl", "sh_test")

def scalafmt_round_trip_test(name, rule_type, filename):
    """Asserts formatted-$rule_type is already formatted, unformatted-$rule_type
    is not, and running the formatter over unformatted-$filename.scala produces
    formatted-$filename.scala.

    Args:
        name: test target name.
        rule_type: the `formatted-$rule_type`/`unformatted-$rule_type` targets'
            common suffix (e.g. `"binary"`, `"custom-conf"`).
        filename: the `formatted-$filename.scala`/`unformatted-$filename.scala`
            source files' common suffix.
    """
    unformatted_src = "unformatted/unformatted-%s.scala" % filename
    sh_test(
        name = name,
        srcs = ["round_trip_test.sh"],
        args = [
            "$(rootpath :formatted-%s.format-test)" % rule_type,
            "$(rootpath :unformatted-%s.format-test)" % rule_type,
            "$(rootpath :unformatted-%s.format)" % rule_type,
            "$(rootpath %s)" % unformatted_src,
            native.package_name() + "/" + unformatted_src,
            "$(rootpath formatted/formatted-%s.scala)" % filename,
        ],
        data = [
            ":formatted-%s" % rule_type,
            ":formatted-%s.format-test" % rule_type,
            ":unformatted-%s" % rule_type,
            ":unformatted-%s.format-test" % rule_type,
            ":unformatted-%s.format" % rule_type,
            unformatted_src,
            "formatted/formatted-%s.scala" % filename,
        ],
        # The .format-test/.format scripts locate their compiled outputs by
        # walking up from their own path to the bazel-out "bin" directory, so
        # they need the real output tree, not a sandbox's runfiles-only copy.
        tags = ["local"],
    )
