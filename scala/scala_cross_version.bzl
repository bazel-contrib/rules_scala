# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Helper functions for Scala cross-version support. Encapsulates the logic
of abstracting over Scala major version (2.11, 2.12, etc) for dependency
resolution."""

def default_maven_server_urls():
    return [
        "https://repo.maven.apache.org/maven2",
        "https://maven-central.storage-download.googleapis.com/maven2",
        "https://mirror.bazel.build/repo1.maven.org/maven2",
        "https://jcenter.bintray.com",
    ]

def extract_major_version(scala_version):
    """Return major Scala version given a full version, e.g. "2.11.11" -> "2.11" """
    return scala_version[:scala_version.find(".", 2)]

def extract_minor_version(scala_version):
    return scala_version.split(".")[2]

def extract_major_version_underscore(scala_version):
    """Return major Scala version with underscore given a full version,
    e.g. "2.11.11" -> "2_11" """
    return extract_major_version(scala_version).replace(".", "_")

def artifact_targets_for_scala_version(desired_scala_version, artifacts):
    """Transform a list of artifacts into a list of targets compatible with the given Scala version.

    Given a list of artifacts defined in `rules_scala_maven.MODULE.bazel`, filter those artifacts compatible with the
    Scala version `desired_scala_version` and transform them into a list of targets underneath
    `@rules_scala_maven//...`.

    If `artifacts` is `None`, this function will return `None`.
    """

    if artifacts == None:
        return None

    desired_scala_version_components = desired_scala_version.split(".")

    def is_compatible(scala_version):
        components = scala_version.split(".")

        if len(components) < len(desired_scala_version_components):
            return desired_scala_version_components[:len(components)] == components

        return components[:len(desired_scala_version_components)] == desired_scala_version_components

    result = []

    for artifact in artifacts:
        if artifact.scala_version == "" or is_compatible(artifact.scala_version):
            result.append(
                # We use the canonical repository name so it resolves in workspaces other than this one
                "@@rules_jvm_external++maven+rules_scala_maven//:{}_{}".format(
                    artifact.group.replace(".", "_").replace("-", "_"),
                    artifact.name.replace(".", "_").replace("-", "_"),
                ),
            )

    return result

def sanitize_version(scala_version):
    """ Makes Scala version usable in target names. """
    return scala_version.replace(".", "_")

def version_suffix(scala_version):
    return "_" + sanitize_version(scala_version)

def _scala_version_transition_impl(settings, attr):
    if attr.scala_version:
        return {"@rules_scala_config//:scala_version": attr.scala_version}
    else:
        return {}

scala_version_transition = transition(
    implementation = _scala_version_transition_impl,
    inputs = [],
    outputs = ["@rules_scala_config//:scala_version"],
)

toolchain_transition_attr = {
    "scala_version": attr.string(),
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
}
