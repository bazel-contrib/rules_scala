#!/usr/bin/env python3
"""Updates `protoc/private/protoc_integrity.bzl`.

`protoc_integrity.bzl` contains the mapping from supported prebuilt `protoc`
platforms to:

- `exec_compatible_with` properties based on `@platforms`
- `integrity` strings for each of the supported `PROTOC_VERSIONS`

Only computes integrity information for a `protoc` distribution if it doesn't
already exist in the integrity file.
"""

from lib.update_integrity import (
    get_artifact_integrity,
    get_integrity_file_path_and_generated_by,
    sorted_semver_keyed_dict,
    stringify_object,
    update_integrity_file,
)


PROTOC_VERSIONS = [
    "33.5",
    "33.4",
    # yanked: https://registry.bazel.build/modules/protobuf/33.3
    "33.2",
    "33.1",
    "33.0",
    "32.1",
    "32.0",
    "31.1",
    "31.0",
    "30.2",
    "30.1",
    "30.0",
    "29.3",
    "29.2",
    "29.1",
    "29.0",
]

PROTOC_RELEASES_URL = "https://github.com/protocolbuffers/protobuf/releases"
PROTOC_DOWNLOAD_SUFFIX = "/download/v{version}/protoc-{version}-{platform}.zip"
PROTOC_DOWNLOAD_URL = PROTOC_RELEASES_URL + PROTOC_DOWNLOAD_SUFFIX

PROTOC_BUILDS = {
    "linux-aarch_64": [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
    "linux-ppcle_64": [
        "@platforms//os:linux",
        "@platforms//cpu:ppc64le",
    ],
    "linux-s390_64": [
        "@platforms//os:linux",
        "@platforms//cpu:s390x",
    ],
    "linux-x86_32": [
        "@platforms//os:linux",
        "@platforms//cpu:x86_32"
    ],
    "linux-x86_64": [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64"
    ],
    "osx-aarch_64": [
        "@platforms//os:osx",
        "@platforms//cpu:aarch64",
    ],
    "osx-x86_64": [
        "@platforms//os:osx",
        "@platforms//cpu:x86_64"
    ],
    "win32": [
        "@platforms//os:windows",
        "@platforms//cpu:x86_32"
    ],
    "win64": [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64"
    ],
}

DATA_MARKER = "PROTOC_BUILDS = "
INTEGRITY_FILE, GENERATED_BY = get_integrity_file_path_and_generated_by(
    'protoc/private/protoc_integrity.bzl',
    __file__,
)
INTEGRITY_FILE_HEADER = f'''"""Protocol compiler build and integrity metadata.

{GENERATED_BY}
"""

PROTOC_RELEASES_URL = "{PROTOC_RELEASES_URL}"
PROTOC_DOWNLOAD_URL = (
    PROTOC_RELEASES_URL +
    "{PROTOC_DOWNLOAD_SUFFIX}"
)

PROTOC_VERSIONS = '''


def get_protoc_integrity(platform, version):
    """Emits the integrity string for the specified `protoc` distribution.

    This will download the distribution specified by applying `platform` and
    `version` to `PROTOC_DOWNLOAD_URL`.

    Args:
        platform: a platform key from `PROTOC_BUILDS`
        version: a valid `protobuf` version specifier

    Returns:
        a string starting with `sha256-` and ending with the base 64 encoded
            sha256 checksum of the `protoc` distribution file

    Raises:
        `UpdateIntegrityError` if downloading or checksumming fails
    """
    url = PROTOC_DOWNLOAD_URL.format(version = version, platform = platform)
    print(f'Updating protoc {version} for {platform}:\n  {url}')
    return get_artifact_integrity(url)


def add_build_data(platform, exec_compat, existing_build):
    """Adds `protoc` integrity data to `existing_build` for new protoc versions.

    Args:
        platform: a platform key from `PROTOC_BUILDS`
        exec_compat: compatibility specifier values from `PROTOC_BUILDS`
        existing_build: an existing `PROTOC_BUILDS` output value for `platform`,
            or `{}` if it doesn't yet exist

    Returns:
        a new dictionary to emit as a `PROTOC_BUILDS` entry in the output file
    """
    integrity = dict(existing_build.get("integrity", {}))

    for version in PROTOC_VERSIONS:
        if version not in integrity:
            integrity[version] = get_protoc_integrity(platform, version)

    return {
        "exec_compat": exec_compat,
        "integrity": sorted_semver_keyed_dict(integrity, reverse=True),
    }


def update_protoc_integrity_data(existing_data):
    """Generates or updates `protoc` integrity data.

    Does not generate new `protoc` integrity data for versions and builds
    already in `existing_data`.

    Args:
        existing_data: existing `protoc` integrity data

    Returns:
        a new `{protobuf version: integrity data}` dict combining existing and
            new `protoc` integrity data
    """
    updated_data = {
        platform: add_build_data(
            platform,
            exec_compat,
            existing_data.get(platform, {}),
        )
        for platform, exec_compat in PROTOC_BUILDS.items()
    }
    return dict(sorted(updated_data.items()))


def emit_protoc_integrity_data(output_file, integrity_data):
    """Writes the updated `protoc` integrity data to the `output_file`.

    Args:
        output_file: open file object for the updated `protoc` integrity file
        integrity_data: `protoc` integrity data to emit into `output_file`
    """
    output_file.write(INTEGRITY_FILE_HEADER)
    output_file.write(stringify_object(PROTOC_VERSIONS))
    output_file.write(DATA_MARKER)
    output_file.write(stringify_object(integrity_data))


if __name__ == "__main__":
    update_integrity_file(
        "Updates prebuilt `protoc` distribution information.",
        INTEGRITY_FILE,
        DATA_MARKER,
        update_protoc_integrity_data,
        emit_protoc_integrity_data,
    )
