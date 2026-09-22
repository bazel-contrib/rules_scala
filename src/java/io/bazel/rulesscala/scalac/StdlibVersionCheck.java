package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.worker.Worker;
import java.io.File;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Fails a scala compile if its classpath carries two incompatible versions of the Scala standard
 * library, naming the mismatched dependency and both versions in the error.
 *
 * <p>Left unguarded, this crashes the compiler with an unreadable error; see
 * https://github.com/bazel-contrib/rules_scala/issues/1781.
 *
 * <p>This runs against the classpath actually passed to the compiler (scalac's own -classpath),
 * built by the existing Starlark dependency-collection logic (direct/plus-one/transitive modes,
 * exports, macro runtime jars). Reading it here, already flattened to a plain list for the
 * compiler's own use, keeps the check at execution time instead of paying an eager
 * depset.to_list() cost during Bazel's analysis phase, and reuses that Starlark exposure logic
 * as is.
 *
 * <p>Scope: this only compares versions of the same artifact (scala3-library_3 against
 * scala3-library_3, scala-library against scala-library). It has nothing to say about a Scala
 * 2-compiled library consumed by a Scala 3 target or vice versa, a separate, binary-incompatible
 * mixing problem.
 */
class StdlibVersionCheck {

  static class MismatchedStdlibVersions extends Worker.Interface.WorkerException {
    MismatchedStdlibVersions(String message) {
      super(message);
    }
  }

  // Basename prefixes of the Scala standard library's own jars.
  private static final String[] STDLIB_JAR_PREFIXES = {"scala3-library_3-", "scala-library-"};

  // Prefixes a compile-jar-producing rule puts in front of those basenames
  // (rules_jvm_external's jvm_import: "header_"; a processed/re-signed jar: "processed_").
  private static final String[] JAR_WRAPPER_PREFIXES = {"header_", "processed_"};

  // Maven classifier suffixes (sources/javadoc jars). scala3-library_3-3.3.1-sources.jar
  // carries "3.3.1-sources" after the prefix; these suffixes catch and skip it.
  private static final String[] NON_COMPILE_CLASSIFIER_SUFFIXES = {"-sources", "-javadoc"};

  private StdlibVersionCheck() {}

  static class ArtifactVersion {
    final String artifact;
    final String version;

    ArtifactVersion(String artifact, String version) {
      this.artifact = artifact;
      this.version = version;
    }
  }

  // If basename is a (possibly wrapped/stamped) stdlib jar, returns its (artifact prefix,
  // version); otherwise null. Package-private so StdlibVersionCheckTest can unit-test it directly.
  static ArtifactVersion stdlibJarVersion(String basename) {
    if (!basename.endsWith(".jar")) {
      return null;
    }
    String name = basename.substring(0, basename.length() - ".jar".length());
    if (name.endsWith("-stamped")) {
      name = name.substring(0, name.length() - "-stamped".length());
    }
    for (String wrapperPrefix : JAR_WRAPPER_PREFIXES) {
      if (name.startsWith(wrapperPrefix)) {
        name = name.substring(wrapperPrefix.length());
        break;
      }
    }
    for (String prefix : STDLIB_JAR_PREFIXES) {
      if (name.startsWith(prefix)) {
        String version = name.substring(prefix.length());

        // A version starts with a digit, excluding a coincidental prefix
        // match like scala-library-utils-1.0.jar.
        if (version.isEmpty() || version.charAt(0) < '0' || version.charAt(0) > '9') {
          continue;
        }
        boolean isClassifierJar = false;
        for (String suffix : NON_COMPILE_CLASSIFIER_SUFFIXES) {
          if (version.endsWith(suffix)) {
            isClassifierJar = true;
            break;
          }
        }
        if (isClassifierJar) {
          continue;
        }
        return new ArtifactVersion(prefix, version);
      }
    }
    return null;
  }

  // The granularity two versions of the same artifact must agree on to coexist
  // on one classpath. scala-library (Scala 2.x) keeps binary compatibility
  // within a major.minor line, so only a major.minor difference matters (mixing
  // 2.12 and 2.13 breaks; 2.12.20 vs 2.12.21 doesn't). scala3-library_3's TASTy
  // format changes with each minor version, so any version difference matters.
  static String compatKey(String artifact, String version) {
    if (artifact.equals("scala-library-")) {
      String[] parts = version.split("\\.", -1);
      return parts.length >= 2 ? parts[0] + "." + parts[1] : version;
    }
    return version;
  }

  // Fails if classpath carries two incompatible versions of the same stdlib artifact.
  static void check(String targetLabel, String[] classpath) {
    Map<String, Map<String, String[]>> versionsByArtifact = new LinkedHashMap<>();

    for (String path : classpath) {
      ArtifactVersion match = stdlibJarVersion(new File(path).getName());
      if (match == null) {
        continue;
      }
      Map<String, String[]> versions =
          versionsByArtifact.computeIfAbsent(match.artifact, k -> new LinkedHashMap<>());
      versions.putIfAbsent(
          compatKey(match.artifact, match.version), new String[] {match.version, path});
    }

    for (Map.Entry<String, Map<String, String[]>> entry : versionsByArtifact.entrySet()) {
      Map<String, String[]> versions = entry.getValue();
      if (versions.size() > 1) {
        String artifact = entry.getKey().substring(0, entry.getKey().length() - 1);
        StringBuilder versionsList = new StringBuilder();
        for (String[] versionAndPath : versions.values()) {
          if (versionsList.length() > 0) {
            versionsList.append(", ");
          }
          versionsList.append(versionAndPath[0]).append(" (").append(versionAndPath[1]).append(")");
        }
        throw new MismatchedStdlibVersions(
            String.format(
                "%s: multiple versions of %s on the compile classpath: %s. A dependency was"
                    + " built against a different version of %s than the toolchain's scala_version"
                    + " resolves; make sure every dependency that carries %s was built against the"
                    + " same version.",
                targetLabel, artifact, versionsList, artifact, artifact));
      }
    }
  }
}
