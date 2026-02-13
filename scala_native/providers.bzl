"""Scala Native providers for Bazel."""

ScalaNativeInfo = provider(
    doc = "Contains Scala Native compilation artifacts (NIR files)",
    fields = {
        "nir_jar": "JAR containing .nir files from this target",
        "transitive_nir_jars": "Depset of all transitive NIR jars from dependencies",
    },
)
