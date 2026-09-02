"""A macro for the tests of scala/private/macros/bzlmod.bzl.

Each test creates a standalone Bazel module that consumes rules_scala through
local_path_override, matching how an external bzlmod consumer sees its module
extensions, then runs a nested `bazel run --enable_bzlmod` and checks its
output against `expect` (must succeed and match) or `expect_fail` (must fail
and match). `expect_fail` may use the placeholder `{MODULE_BAZEL}` for the
"at <path>/MODULE.bazel:<line>" location bazel appends to a module-extension
tag error; the placeholder expands to a regex broad enough to match any
tmpdir path, since only the message text needs a precise match.

Each test's config (target/tag_lines/expect) is written to a small text file
at build time and passed to the script as a single `$(rootpath)` argument,
rather than as individual `args` entries. A tag line or regex can contain
spaces, `$`, quotes and parens, and those survive an ordinary `sh_test` `args`
entry inconsistently across platforms: Bazel's own args handling needs `$`
doubled and spaces quoted, and the Windows test launcher rebuilds a `bash -c`
command line from `args` using its own incomplete quoting (confirmed via a
real CI run: an unquoted `test_ext.single_test_tag()` broke bash's parser on
its parens). A `$(rootpath)` value is a plain package-relative path (letters,
digits, `/`, `_`, `.`), so it survives every platform's argument handling
intact, and a shell reads the config text exactly once: this script's own
`while read` loop.
"""

load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

_MODULE_BAZEL_REGEX = "[^ ]+MODULE[.]bazel"

_NESTED_BAZEL_DATA = [
    "//:.bazelrc",
    "//:.bazelversion",
    "//:MODULE.bazel",
    "//:MODULE.bazel.lock",
    "//:deps/latest/MODULE.bazel",
    "//scala/private:macros/bzlmod.bzl",
    "//test/expect_build_failure:nested_bazel.sh",
    ":BUILD.bzlmod_test",
    ":MODULE.bzlmod_test",
    ":MODULE.bzlmod_test_root_module",
    ":bzlmod_test_ext.bzl",
]

_NESTED_BAZEL_TAGS = [
    "exclusive",
    "local",
    "requires-network",
]

def bzlmod_macro_test(name, target, tag_lines = [], expect = None, expect_fail = None):
    """A test that runs `target` (with `tag_lines` appended to MODULE.bazel) and checks its output.

    Args:
        name: the test target's name
        target: the label to `bazel run --enable_bzlmod`, e.g. "//:print-single-test-tag-values"
        tag_lines: MODULE.bazel lines appended after the module declaration, e.g.
            'test_ext.single_test_tag(first = "quux")'
        expect: a regex the run's combined stdout/stderr must match on success
        expect_fail: a regex the run's combined stdout/stderr must match on failure;
            may contain the `{MODULE_BAZEL}` placeholder (see the file docstring)
    """
    if (expect == None) == (expect_fail == None):
        fail("bzlmod_macro_test %s: pass exactly one of expect or expect_fail" % name)

    config_lines = ["TARGET=%s" % target]
    config_lines += ["TAG=%s" % line for line in tag_lines]
    if expect != None:
        config_lines.append("EXPECT=%s" % expect)
    else:
        config_lines.append(
            "EXPECT_FAIL=%s" % expect_fail.replace("{MODULE_BAZEL}", _MODULE_BAZEL_REGEX),
        )

    config_name = "%s_config" % name
    write_file(
        name = config_name,
        out = "%s.txt" % config_name,
        content = config_lines,
        newline = "unix",
    )

    sh_test(
        name = name,
        size = "large",
        srcs = ["bzlmod_macros_test.sh"],
        args = ["$(rootpath :%s)" % config_name],
        data = _NESTED_BAZEL_DATA + [":" + config_name],
        tags = _NESTED_BAZEL_TAGS,
    )

def bzlmod_fake_root_module_test(name):
    """The one test case whose fixture wraps a second Bazel module around the first."""
    sh_test(
        name = name,
        size = "large",
        srcs = ["bzlmod_macros_test.sh"],
        args = ["--fake-root-module-tags"],
        data = _NESTED_BAZEL_DATA,
        tags = _NESTED_BAZEL_TAGS,
    )
