#!/usr/bin/env python3
"""Updates `scala/private/macros/compiler_sources_integrity.bzl`.

`compiler_sources_integrity.bzl` contains the mapping from Scala versions to
their source URLs and integrity hashes.

Only computes the integrity information for compiler versions that don't already
exist in the integrity file.
"""

from lib.update_integrity import (
    get_artifact_integrity,
    get_integrity_file_path_and_generated_by,
    sorted_semver_keyed_dict,
    stringify_object,
    update_integrity_file,
)


# These are matched with the versions from //dt_patches:dt_patch_test.sh.
SCALA_VERSIONS = [
    "2.11.12",
] + [
    f'2.12.{patch}' for patch in range(1, 22)  # 2.12.1 to 2.12.21
] + [
    f'2.13.{patch}' for patch in range(0, 19)  # 2.13.0 to 2.13.18
] + [
    f'3.1.{patch}' for patch in range(0, 4)    # 3.1.0  to 3.1.3
] + [
    f'3.2.{patch}' for patch in range(0, 3)    # 3.2.0  to 3.2.2
] + [
    f'3.3.{patch}' for patch in range(0, 8)    # 3.3.0  to 3.3.7
] + [
    f'3.4.{patch}' for patch in range(0, 4)    # 3.4.0  to 3.4.3
] + [
    f'3.5.{patch}' for patch in range(0, 3)    # 3.5.0  to 3.5.2
] + [
    f'3.6.{patch}' for patch in range(0, 5)    # 3.6.0  to 3.6.4
] + [
    f'3.7.{patch}' for patch in range(0, 5)    # 3.7.0  to 3.7.4
] + [
    f'3.8.{patch}' for patch in range(0, 3)    # 3.8.0  to 3.8.2
]

DATA_MARKER = "COMPILER_SOURCES = "
URL_PREFIX = "https://repo1.maven.org/maven2/org/scala-lang/"
URL_SUFFIX_BY_MAJOR_VERSION = {
    "2": "scala-compiler/{version}/scala-compiler-{version}-sources.jar",
    "3": "scala3-compiler_3/{version}/scala3-compiler_3-{version}-sources.jar",
}

INTEGRITY_FILE, GENERATED_BY = get_integrity_file_path_and_generated_by(
    'scala/private/macros/compiler_sources_integrity.bzl',
    __file__,
)
INTEGRITY_FILE_HEADER = f'''"""Scala compiler source JAR integrity metadata.

{GENERATED_BY}
"""

URL_PREFIX = "{URL_PREFIX}"
URL_SUFFIX_BY_MAJOR_VERSION = '''


class UpdateCompilerSourcesIntegrityError(Exception):
    """Errors raised explicitly by this module."""


def get_compiler_source_integrity(scala_version):
    """Generates the URL and integrity value for a specific Scala version.

    Args:
        scala_version: the scala version for which to generate a URL and
            integrity value

    Returns:
        a `{"url", "integrity"}` dict for the `scala_version` compiler sources
    """
    major_version = scala_version.split(".", 1)[0]
    url_suffix = URL_SUFFIX_BY_MAJOR_VERSION.get(major_version, None)

    if url_suffix is None:
        msg = "unknown major Scala version: " + scala_version
        raise UpdateCompilerSourcesIntegrityError(msg)

    url = URL_PREFIX + url_suffix.format(version = scala_version)
    print(f'Generating integrity for:\n  {url}')
    return {"url": url, "integrity": get_artifact_integrity(url)}


def update_compiler_sources_integrity_data(existing_data):
    """Generates or updates compiler sources integrity data.

    Does not generate new compiler source integrity data for Scala versions
    already in `existing_data`.

    Args:
        existing_data: existing compiler source integrity data

    Returns:
        a new `{scala version: integrity data}` dict combining existing and new
            compiler sources integrity data
    """
    updated_data = existing_data | {
        version: get_compiler_source_integrity(version)
        for version in SCALA_VERSIONS
        if version not in existing_data
    }
    return sorted_semver_keyed_dict(updated_data)


def emit_compiler_sources_integrity_data(output_file, integrity_data):
    """Writes the updated compiler_sources integrity data to the `output_file`.

    Args:
        output_file: open file object for the updated compiler sources integrity
            file
        integrity_data: compiler sources integrity data to emit into
            `output_file`
    """
    output_file.write(INTEGRITY_FILE_HEADER)
    output_file.write(stringify_object(URL_SUFFIX_BY_MAJOR_VERSION))
    output_file.write(DATA_MARKER)
    output_file.write(stringify_object(integrity_data))


if __name__ == "__main__":
    update_integrity_file(
        "Updates Scala compiler source JAR integrity information.",
        INTEGRITY_FILE,
        DATA_MARKER,
        update_compiler_sources_integrity_data,
        emit_compiler_sources_integrity_data,
    )
