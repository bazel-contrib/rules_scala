"""Fails a scala compile if its classpath carries two incompatible versions of
the Scala standard library, naming the mismatched dependency and both
versions in the error.

Left unguarded, this crashes the compiler with an unreadable error; see
https://github.com/bazel-contrib/rules_scala/issues/1781.
"""

# Basename prefixes of the Scala standard library's own jars.
_STDLIB_JAR_PREFIXES = ["scala3-library_3-", "scala-library-"]

# Prefixes a compile-jar-producing rule puts in front of those basenames
# (rules_jvm_external's jvm_import: "header_"; a processed/re-signed jar: "processed_").
_JAR_WRAPPER_PREFIXES = ["header_", "processed_"]
_DIGITS = "0123456789"

# Maven classifier suffixes (sources/javadoc jars); matching one would parse
# a bogus "version" out of e.g. scala3-library_3-3.3.1-sources.jar.
_NON_COMPILE_CLASSIFIER_SUFFIXES = ["-sources", "-javadoc"]

# If basename is a (possibly wrapped/stamped) stdlib jar, returns its
# (artifact prefix, version); otherwise (None, None). Exported so
# stdlib_version_check_test.bzl can unit-test it directly.
def stdlib_jar_version(basename):
    if not basename.endswith(".jar"):
        return None, None
    name = basename[:-len(".jar")]
    if name.endswith("-stamped"):
        name = name[:-len("-stamped")]
    for wrapper_prefix in _JAR_WRAPPER_PREFIXES:
        if name.startswith(wrapper_prefix):
            name = name[len(wrapper_prefix):]
            break
    for prefix in _STDLIB_JAR_PREFIXES:
        if name.startswith(prefix):
            version = name[len(prefix):]

            # A version starts with a digit, excluding a coincidental prefix
            # match like scala-library-utils-1.0.jar.
            if not version or version[0] not in _DIGITS:
                continue
            if any([version.endswith(suffix) for suffix in _NON_COMPILE_CLASSIFIER_SUFFIXES]):
                continue
            return prefix, version
    return None, None

# The granularity two versions of the same artifact must agree on to coexist
# on one classpath. scala-library (Scala 2.x) keeps binary compatibility
# within a major.minor line, so only a major.minor difference matters (mixing
# 2.12 and 2.13 breaks; 2.12.20 vs 2.12.21 doesn't). scala3-library_3's TASTy
# format changes with each minor version, so any version difference matters.
def compat_key(artifact, version):
    if artifact == "scala-library-":
        return ".".join(version.split(".")[:2])
    return version

# Fails if classpath_jars carries two incompatible versions of the same
# stdlib artifact.
def fail_on_mismatched_stdlib_versions(target_label, classpath_jars):
    versions_by_artifact = {}
    for jar in classpath_jars.to_list():
        artifact, version = stdlib_jar_version(jar.basename)
        if artifact == None:
            continue
        key = compat_key(artifact, version)
        versions_by_artifact.setdefault(artifact, {}).setdefault(key, (version, jar.path))

    for artifact, versions in versions_by_artifact.items():
        if len(versions) > 1:
            fail((
                "{target}: multiple versions of {artifact} on the compile " +
                "classpath: {versions}. A dependency was built against a " +
                "different version of {artifact} than the toolchain's " +
                "scala_version resolves; make sure every dependency that " +
                "carries {artifact} was built against the same version."
            ).format(
                target = target_label,
                artifact = artifact.rstrip("-"),
                versions = ", ".join([
                    "%s (%s)" % (version, path)
                    for version, path in versions.values()
                ]),
            ))
