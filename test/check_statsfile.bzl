def check_statsfile(target):
    _check_statsfile(target, "!")

def check_statsfile_empty(target):
    # This only holds under a stats-file-disabled toolchain (see the explicit
    # --extra_toolchains build in test_rules_scala.sh); under the default
    # toolchain the stats file is populated and the genrule fails. Tag it
    # "manual" so wildcard builds (e.g. `bazel build //...`) skip it while the
    # explicit build still works.
    _check_statsfile(target, tags = ["manual"])

def _check_statsfile(target, predicate = "", tags = []):
    statsfile = ":%s.statsfile" % target
    outfile = "%s.statsfile.good" % target

    cmd = """
TIME_MS=`awk -F '=' '$$1 == "build_time" {{ print $$2 }}' {statsfile}`
if [ """ + predicate + """ -z "$$TIME_MS" ]; then
  touch '{outfile}'
fi
"""
    cmd = cmd.format(
        statsfile = "$(location %s)" % statsfile,
        outfile = "$(location %s)" % outfile,
    )

    native.genrule(
        name = "%s_statsfile" % target,
        outs = [outfile],
        tools = [statsfile],
        cmd = cmd,
        tags = tags,
        visibility = ["//visibility:public"],
    )
