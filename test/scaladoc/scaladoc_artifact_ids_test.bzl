"""Unit tests for scaladoc_artifact_ids (scala/private/macros/scala_repositories.bzl)."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//scala/private:macros/scala_repositories.bzl",
    "SCALADOC_ARTIFACT_ID",
    "scaladoc_artifact_ids",
)
load(
    "//third_party/repositories:repositories.bzl",
    "artifacts_by_major_scala_version",
    "scala_version_by_major_scala_version",
    "scaladoc_artifact_ids_by_major_scala_version",
)

def _generated_list_matches_deps_test(ctx):
    env = unittest.begin(ctx)

    for major, generated in scaladoc_artifact_ids_by_major_scala_version.items():
        # An override of the Scaladoc artifact with its own metadata makes
        # scaladoc_artifact_ids follow the deps.
        walked = scaladoc_artifact_ids(
            scala_version_by_major_scala_version[major],
            {
                SCALADOC_ARTIFACT_ID: artifacts_by_major_scala_version[major][
                    SCALADOC_ARTIFACT_ID
                ],
            },
        )
        asserts.equals(
            env,
            sorted(walked),
            sorted(generated),
            "scaladoc_artifact_ids in scala_%s.bzl is out of date. " %
            major.replace(".", "_") + "Run scripts/create_repository.py.",
        )

    return unittest.end(env)

def _override_adds_dep_test(ctx):
    env = unittest.begin(ctx)
    scaladoc = artifacts_by_major_scala_version["3.3"][SCALADOC_ARTIFACT_ID]
    override = {
        SCALADOC_ARTIFACT_ID: scaladoc | {
            "deps": scaladoc["deps"] + ["@added_dep"],
        },
    }

    asserts.true(
        env,
        "added_dep" in scaladoc_artifact_ids("3.3.4", override),
        "expected the dep that the override adds",
    )
    asserts.false(
        env,
        "added_dep" in scaladoc_artifact_ids("3.3.4"),
        "expected only the generated ids with the default artifacts",
    )

    generated = scaladoc_artifact_ids_by_major_scala_version["3.3"]
    transitive_id = [id for id in generated if id != SCALADOC_ARTIFACT_ID][0]
    transitive = artifacts_by_major_scala_version["3.3"][transitive_id]
    asserts.true(
        env,
        "added_dep" in scaladoc_artifact_ids("3.3.4", {
            transitive_id: transitive | {
                "runtime_deps": transitive.get("runtime_deps", []) + ["@added_dep"],
            },
        }),
        "expected the runtime dep that the override of %s adds" % transitive_id,
    )

    return unittest.end(env)

generated_list_matches_deps_test = unittest.make(
    _generated_list_matches_deps_test,
)
override_adds_dep_test = unittest.make(_override_adds_dep_test)

def scaladoc_artifact_ids_test_suite(name):
    unittest.suite(
        name,
        generated_list_matches_deps_test,
        override_adds_dep_test,
    )
