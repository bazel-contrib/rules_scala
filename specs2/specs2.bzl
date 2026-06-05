def specs2_artifact_ids(scala_version = None):
    ids = [
        "io_bazel_rules_scala_org_specs2_specs2_common",
        "io_bazel_rules_scala_org_specs2_specs2_core",
        "io_bazel_rules_scala_org_specs2_specs2_fp",
        "io_bazel_rules_scala_org_specs2_specs2_matcher",
    ]
    if scala_version != None and scala_version.startswith("3."):
        ids.append("io_bazel_rules_scala_org_portable_scala_portable_scala_reflect_2_13")
    return ids

def specs2_dependencies():
    return [Label("//specs2:specs2")]
