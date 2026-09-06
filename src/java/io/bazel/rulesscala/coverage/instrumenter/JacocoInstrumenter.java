package io.bazel.rulesscala.coverage.instrumenter;

import io.bazel.rulesscala.io_utils.DeleteRecursively;
import io.bazel.rulesscala.jar.JarCreator;
import io.bazel.rulesscala.worker.Worker;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.FileVisitor;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.StandardOpenOption;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import org.jacoco.core.instr.Instrumenter;
import org.jacoco.core.runtime.OfflineInstrumentationAccessGenerator;

public final class JacocoInstrumenter implements Worker.Interface {

  /**
   * Separates the real source path from the class-derived path in a {@code
   * -paths-for-coverage.txt} entry. Must stay in sync with {@code
   * JacocoLCOVFormatter.EXEC_PATH_DELIMITER}.
   */
  private static final String EXEC_PATH_DELIMITER = "///";

  public static void main(String[] args) throws Exception {
    Worker.workerMain(args, new JacocoInstrumenter());
  }

  @Override
  public void work(String[] args) throws Exception {
    Instrumenter jacoco = new Instrumenter(new OfflineInstrumentationAccessGenerator());
    processArg(jacoco, args);
  }

  private void processArg(Instrumenter jacoco, String[] args) throws Exception {
    if (args.length < 3) {
      throw new Exception(
          "expected format `in_path out_path src1 src2 ... srcN`  for arguments: "
              + Arrays.asList(args));
    }

    Path inPath = Paths.get(args[0]);
    Path outPath = Paths.get(args[1]);
    String[] srcs = Arrays.copyOfRange(args, 2, args.length);

    // Use a directory for coverage metadata that is unique to each built jar. Avoids
    // multiple threads performing read/write/delete actions on the instrumented classes directory.
    Path instrumentedClassesDirectory = getMetadataDirRelativeToJar(outPath);
    Files.createDirectories(instrumentedClassesDirectory);

    JarCreator jarCreator = new JarCreator(outPath);

    // Jar-relative paths of every class we instrument, e.g. `/com/example/util/Time$.class`.
    // Collected during the walk below and used to map sources onto their packages.
    Set<String> classEntries = new LinkedHashSet<>();

    try (FileSystem inFS = FileSystems.newFileSystem(inPath, (ClassLoader) null)) {
      FileVisitor fileVisitor =
          createInstrumenterVisitor(jacoco, instrumentedClassesDirectory, jarCreator, classEntries);
      inFS.getRootDirectories()
          .forEach(
              root -> {
                try {
                  Files.walkFileTree(root, fileVisitor);
                } catch (final Exception e) {
                  throw new RuntimeException(e);
                }
              });

      /*
       * https://github.com/bazelbuild/bazel/blob/567ca633d016572f5760bfd027c10616f2b8c2e4/src/java_tools/junitrunner/java/com/google/testing/coverage/JacocoCoverageRunner.java#L411
       *
       * Bazel / JacocoCoverageRunner will look for any file that ends with '-paths-for-coverage.txt' within the JAR to be later used for reconstructing the path for source files.
       * This is a fairly undocumented feature within bazel at this time, but in essence, it opens all the jars, searches for all files matching '-paths-for-coverage.txt'
       * and then adds them to a single in memory set.
       *
       * https://github.com/bazelbuild/bazel/blob/567ca633d016572f5760bfd027c10616f2b8c2e4/src/java_tools/junitrunner/java/com/google/testing/coverage/JacocoLCOVFormatter.java#L70
       * Which is then used in the formatter to find the corresponding source file from the set of sources we wrote in all the JARs.
       */
      Path pathsForCoverage = instrumentedClassesDirectory.resolve("-paths-for-coverage.txt");
      Files.write(
          pathsForCoverage,
          pathsForCoverageContent(srcs, classEntries)
              .getBytes(java.nio.charset.StandardCharsets.UTF_8));

      jarCreator.addEntry(
          instrumentedClassesDirectory.relativize(pathsForCoverage).toString(), pathsForCoverage);
      jarCreator.setCompression(true);
      jarCreator.execute();
    } finally {
      DeleteRecursively.run(instrumentedClassesDirectory);
    }
  }

  // Return the path of the coverage metadata directory relative to the output jar path.
  private static Path getMetadataDirRelativeToJar(Path outputJar) {
    return outputJar.resolveSibling(outputJar + "-coverage-metadata");
  }

  /**
   * Builds the contents of `-paths-for-coverage.txt`.
   *
   * <p>Bazel's {@code JacocoLCOVFormatter} keys coverage data by the class-derived path {@code
   * <package>/<SourceFileName>} and resolves it against this file with a suffix match, so a source
   * file only gets attributed coverage when its path on disk happens to end with its package path.
   * That holds for a Maven-style {@code src/main/scala/com/example/util/Time.scala} layout and
   * fails for everything else: when {@code util/time/Time.scala} declares {@code package
   * com.example.util}, nothing matches and the file is left out of the report entirely. See
   * https://github.com/bazel-contrib/rules_scala/issues/1101.
   *
   * <p>The formatter also accepts an explicit mapping, {@code <real path>///<class-derived path>},
   * which skips the suffix match (added in https://github.com/bazelbuild/bazel/pull/12627). The
   * {@code package} clause isn't readable from here (sources are passed as paths, not declared as
   * inputs to this action), but the jar we just walked names every package it contains, so we emit
   * one mapping per (source, package) pair. A pair that doesn't describe a real class is simply
   * never looked up. Pairs whose package holds a class named after the source file are emitted
   * first so that two sources sharing a basename in one jar still resolve correctly.
   *
   * <p>The bare source paths are kept at the end, preserving the previous behaviour for layouts
   * where the suffix match already works.
   */
  static String pathsForCoverageContent(String[] srcs, Set<String> classEntries) {
    Set<String> packageDirs = new LinkedHashSet<>();
    Set<String> outerClassPaths = new HashSet<>();
    for (String classEntry : classEntries) {
      packageDirs.add(packageDirOf(classEntry));
      outerClassPaths.add(outerClassPathOf(classEntry));
    }

    List<String> preferred = new ArrayList<>();
    List<String> rest = new ArrayList<>();
    for (String packageDir : packageDirs) {
      for (String src : srcs) {
        String fileName = src.substring(src.lastIndexOf('/') + 1);
        String mapping = src + EXEC_PATH_DELIMITER + packageDir + "/" + fileName;
        if (outerClassPaths.contains(packageDir + "/" + stripExtension(fileName))) {
          preferred.add(mapping);
        } else {
          rest.add(mapping);
        }
      }
    }

    List<String> lines = new ArrayList<>(preferred);
    lines.addAll(rest);
    lines.addAll(Arrays.asList(srcs));
    return String.join("\n", lines);
  }

  /** `/com/example/util/Time$.class` -> `/com/example/util`; the default package -> `""`. */
  private static String packageDirOf(String classEntry) {
    int lastSlash = classEntry.lastIndexOf('/');
    return lastSlash <= 0 ? "" : classEntry.substring(0, lastSlash);
  }

  /**
   * `/com/example/util/Cron$CronExpression.class` -> `/com/example/util/Cron`, i.e. the package
   * directory plus the outermost class name, which for Scala is usually the source file's basename.
   */
  private static String outerClassPathOf(String classEntry) {
    String withoutExtension = stripExtension(classEntry);
    int firstDollar = withoutExtension.indexOf('$', withoutExtension.lastIndexOf('/') + 1);
    return firstDollar < 0 ? withoutExtension : withoutExtension.substring(0, firstDollar);
  }

  private static String stripExtension(String path) {
    int lastDot = path.lastIndexOf('.');
    return lastDot <= path.lastIndexOf('/') ? path : path.substring(0, lastDot);
  }

  private SimpleFileVisitor createInstrumenterVisitor(
      Instrumenter jacoco,
      Path instrumentedClassesDirectory,
      JarCreator jarCreator,
      Set<String> classEntries) {
    return new SimpleFileVisitor<Path>() {
      @Override
      public FileVisitResult visitFile(Path inPath, BasicFileAttributes attrs) {
        try {
          return actuallyVisitFile(inPath, attrs);
        } catch (final Exception e) {
          throw new RuntimeException(e);
        }
      }

      @Override
      public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs)
          throws IOException {
        Objects.requireNonNull(dir);
        Objects.requireNonNull(attrs);
        // Adding non-root directories to the jar
        if (!dir.toString().equals("/")) {
          jarCreator.addEntry(dir.toString(), dir);
        }
        return FileVisitResult.CONTINUE;
      }

      private FileVisitResult actuallyVisitFile(Path inPath, BasicFileAttributes attrs)
          throws Exception {
        if (inPath.toString().endsWith(".class")) {
          // Create a tempPath (that is independent of the name), to avoid "File name too long"
          // exceptions.
          Path tempPath =
              Files.createTempFile(instrumentedClassesDirectory, "instrumented", ".jar");
          Files.delete(tempPath);

          try (BufferedInputStream inStream =
                  new BufferedInputStream(Files.newInputStream(inPath));
              BufferedOutputStream outStream =
                  new BufferedOutputStream(
                      Files.newOutputStream(tempPath, StandardOpenOption.CREATE_NEW)); ) {
            jacoco.instrument(inStream, outStream, inPath.toString());
          }
          classEntries.add(inPath.toString());
          jarCreator.addEntry(inPath.toString(), tempPath);
          jarCreator.addEntry(inPath.toString() + ".uninstrumented", inPath);
        } else {
          jarCreator.addEntry(inPath.toString(), inPath);
        }
        return FileVisitResult.CONTINUE;
      }
    };
  }
}
