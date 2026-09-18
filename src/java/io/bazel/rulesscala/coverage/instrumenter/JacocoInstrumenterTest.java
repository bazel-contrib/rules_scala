package io.bazel.rulesscala.coverage.instrumenter;

import static org.junit.Assert.assertEquals;

import java.util.LinkedHashSet;
import java.util.Set;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class JacocoInstrumenterTest {

  @Test
  public void emitsAnExplicitMappingForAUniqueBasename() {
    String[] srcs = {"a/com/example/Foo.scala"};
    Set<String> instrumentedClassPaths = new LinkedHashSet<>();
    instrumentedClassPaths.add("/com/example/Foo.class");

    String result = JacocoInstrumenter.pathsForCoverageContent(srcs, instrumentedClassPaths);

    assertEquals(
        "a/com/example/Foo.scala////com/example/Foo.scala\n" + "a/com/example/Foo.scala", result);
  }

  @Test
  public void skipsTheExplicitMappingWhenTwoSourcesShareABasename() {
    String[] srcs = {"a/Foo.scala", "b/Foo.scala"};
    Set<String> instrumentedClassPaths = new LinkedHashSet<>();
    instrumentedClassPaths.add("/pkg1/Foo.class");
    instrumentedClassPaths.add("/pkg2/Foo.class");

    String result = JacocoInstrumenter.pathsForCoverageContent(srcs, instrumentedClassPaths);

    assertEquals("a/Foo.scala\nb/Foo.scala", result);
  }

  @Test
  public void emitsNoMappingForAPairThatDoesNotDescribeARealClass() {
    // A mapping that doesn't name a real class in this target is still a mapping some
    // other target's real class could collide with once every target's file is combined
    // into one set for the whole coverage run, so pairs like (a/Foo.scala, pkg "/b") below
    // must not appear at all, not just be deprioritized.
    String[] srcs = {"a/Foo.scala", "b/Bar.scala"};
    Set<String> instrumentedClassPaths = new LinkedHashSet<>();
    instrumentedClassPaths.add("/a/Foo.class");
    instrumentedClassPaths.add("/b/Bar.class");

    String result = JacocoInstrumenter.pathsForCoverageContent(srcs, instrumentedClassPaths);

    assertEquals(
        "a/Foo.scala////a/Foo.scala\n"
            + "b/Bar.scala////b/Bar.scala\n"
            + "a/Foo.scala\n"
            + "b/Bar.scala",
        result);
  }

  @Test
  public void skipsTheExplicitMappingWhenABasenameMatchesClassesInTwoPackages() {
    // A class named after this source exists in two different packages -- one of them
    // declared by some other source, not this one. Which package this source's own class
    // landed in isn't recoverable from a name match alone, so neither pairing is emitted.
    String[] srcs = {"Foo.scala", "Other.scala"};
    Set<String> instrumentedClassPaths = new LinkedHashSet<>();
    instrumentedClassPaths.add("/a/Foo.class");
    instrumentedClassPaths.add("/b/Foo.class");

    String result = JacocoInstrumenter.pathsForCoverageContent(srcs, instrumentedClassPaths);

    assertEquals("Foo.scala\nOther.scala", result);
  }

  @Test
  public void outerClassPathOfTakesTheOutermostNameNotTheInnermost() {
    // A doubly-nested class: the outer class is `Cron`, not `Cron$CronExpression`. Taking the
    // last `$` instead of the first would return the wrong (inner) class path.
    assertEquals(
        "/com/example/Cron",
        JacocoInstrumenter.outerClassPathOf("/com/example/Cron$CronExpression$Builder.class"));
  }

  @Test
  public void packageDirOfHandlesTheDefaultPackage() {
    assertEquals("", JacocoInstrumenter.packageDirOf("/Foo.class"));
  }
}
