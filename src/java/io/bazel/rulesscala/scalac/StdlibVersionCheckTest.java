package io.bazel.rulesscala.scalac;

import static org.junit.Assert.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class StdlibVersionCheckTest {

  @Test
  public void stdlibJarVersion_scala3Library() {
    StdlibVersionCheck.ArtifactVersion match =
        StdlibVersionCheck.stdlibJarVersion("scala3-library_3-3.7.4.jar");
    assertEquals("scala3-library_3-", match.artifact);
    assertEquals("3.7.4", match.version);
  }

  @Test
  public void stdlibJarVersion_scalaLibrary() {
    StdlibVersionCheck.ArtifactVersion match =
        StdlibVersionCheck.stdlibJarVersion("scala-library-2.13.18.jar");
    assertEquals("scala-library-", match.artifact);
    assertEquals("2.13.18", match.version);
  }

  @Test
  public void stdlibJarVersion_stamped() {
    StdlibVersionCheck.ArtifactVersion match =
        StdlibVersionCheck.stdlibJarVersion("scala3-library_3-3.7.4-stamped.jar");
    assertEquals("scala3-library_3-", match.artifact);
    assertEquals("3.7.4", match.version);
  }

  @Test
  public void stdlibJarVersion_headerPrefixed() {
    StdlibVersionCheck.ArtifactVersion match =
        StdlibVersionCheck.stdlibJarVersion("header_scala3-library_3-3.7.4.jar");
    assertEquals("scala3-library_3-", match.artifact);
    assertEquals("3.7.4", match.version);
  }

  @Test
  public void stdlibJarVersion_headerPrefixedAndStamped() {
    StdlibVersionCheck.ArtifactVersion match =
        StdlibVersionCheck.stdlibJarVersion("header_scala3-library_3-3.7.4-stamped.jar");
    assertEquals("scala3-library_3-", match.artifact);
    assertEquals("3.7.4", match.version);
  }

  @Test
  public void stdlibJarVersion_coincidentalPrefix_noMatch() {
    // scala-library-utils merely shares the prefix.
    assertNull(StdlibVersionCheck.stdlibJarVersion("scala-library-utils-1.0.jar"));
  }

  @Test
  public void stdlibJarVersion_sourcesClassifier_noMatch() {
    assertNull(StdlibVersionCheck.stdlibJarVersion("scala3-library_3-3.3.1-sources.jar"));
  }

  @Test
  public void stdlibJarVersion_javadocClassifier_noMatch() {
    assertNull(StdlibVersionCheck.stdlibJarVersion("scala3-library_3-3.3.1-javadoc.jar"));
  }

  @Test
  public void stdlibJarVersion_unrelatedJar_noMatch() {
    assertNull(StdlibVersionCheck.stdlibJarVersion("guava-21.0.jar"));
  }

  @Test
  public void stdlibJarVersion_notAJar_noMatch() {
    assertNull(StdlibVersionCheck.stdlibJarVersion("scala3-library_3-3.7.4.txt"));
  }

  @Test
  public void compatKey_scalaLibraryIgnoresPatch() {
    assertEquals("2.12", StdlibVersionCheck.compatKey("scala-library-", "2.12.21"));
  }

  @Test
  public void compatKey_scala3LibraryExact() {
    assertEquals("3.7.4", StdlibVersionCheck.compatKey("scala3-library_3-", "3.7.4"));
  }

  @Test
  public void check_mismatchedScala3LibraryVersions_fails() {
    StdlibVersionCheck.MismatchedStdlibVersions exception =
        assertThrows(
            StdlibVersionCheck.MismatchedStdlibVersions.class,
            () ->
                StdlibVersionCheck.check(
                    "//test:app",
                    new String[] {
                      "bazel-out/bin/scala3-library_3-3.6.4.jar",
                      "bazel-out/bin/scala3-library_3-3.7.4.jar",
                    }));
    assertTrue(exception.getMessage().contains("multiple versions of scala3-library_3"));
  }

  @Test
  public void check_scalaLibraryPatchOnlyDifference_passes() {
    StdlibVersionCheck.check(
        "//test:app",
        new String[] {
          "bazel-out/bin/scala-library-2.13.18.jar", "bazel-out/bin/scala-library-2.13.99.jar",
        });
  }

  @Test
  public void check_scalaLibraryMajorMinorDifference_fails() {
    StdlibVersionCheck.MismatchedStdlibVersions exception =
        assertThrows(
            StdlibVersionCheck.MismatchedStdlibVersions.class,
            () ->
                StdlibVersionCheck.check(
                    "//test:app",
                    new String[] {
                      "bazel-out/bin/scala-library-2.12.21.jar",
                      "bazel-out/bin/scala-library-2.13.18.jar",
                    }));
    assertTrue(exception.getMessage().contains("multiple versions of scala-library"));
  }

  @Test
  public void check_sameVersionDifferentPaths_passes() {
    StdlibVersionCheck.check(
        "//test:app",
        new String[] {
          "bazel-out/a/scala3-library_3-3.6.4.jar", "bazel-out/b/scala3-library_3-3.6.4.jar",
        });
  }

  @Test
  public void check_headerPrefixedMismatch_fails() {
    StdlibVersionCheck.MismatchedStdlibVersions exception =
        assertThrows(
            StdlibVersionCheck.MismatchedStdlibVersions.class,
            () ->
                StdlibVersionCheck.check(
                    "//test:app",
                    new String[] {
                      "bazel-out/bin/scala3-library_3-3.6.4.jar",
                      "bazel-out/bin/header_scala3-library_3-3.7.4.jar",
                    }));
    assertTrue(exception.getMessage().contains("multiple versions of scala3-library_3"));
  }
}
