"""Fast tests for the shared compiler tracking environment parser."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//:scala_config.bzl", "parse_compiler_dependency_tracking")

def _valid_values_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, True, parse_compiler_dependency_tracking("True"))
    asserts.equals(env, False, parse_compiler_dependency_tracking("False"))
    return unittest.end(env)

valid_values_test = unittest.make(_valid_values_test)

def _invalid_value_impl(ctx):
    parse_compiler_dependency_tracking(ctx.attr.value)
    return []

_invalid_value_rule = rule(
    implementation = _invalid_value_impl,
    attrs = {"value": attr.string()},
)

def _invalid_value_test(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ctx.attr.message)
    return analysistest.end(env)

invalid_value_test = analysistest.make(
    _invalid_value_test,
    expect_failure = True,
    attrs = {"message": attr.string()},
)

def compiler_dependency_tracking_test_suite(name):
    tests = [name + "_valid"]
    valid_values_test(name = tests[0])

    for suffix, value in [("lowercase", "true"), ("empty", ""), ("other", "1")]:
        target = name + "_" + suffix + "_value"
        test = name + "_" + suffix
        # Intentionally fails analysis; exclude it from wildcard //... builds.
        _invalid_value_rule(name = target, value = value, tags = ["manual"])
        invalid_value_test(
            name = test,
            target_under_test = ":" + target,
            message = "ENABLE_COMPILER_DEPENDENCY_TRACKING must be True or False, got %r" % value,
        )
        tests.append(test)

    native.test_suite(name = name, tests = tests)
