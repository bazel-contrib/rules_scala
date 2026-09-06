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
import java.util.Arrays;
import java.util.Objects;
import org.jacoco.core.instr.Instrumenter;
import org.jacoco.core.runtime.OfflineInstrumentationAccessGenerator;

public final class JacocoInstrumenter implements Worker.Interface {

  /**
   * Pass classes whose instrumentation would push a method past the JVM's 64KB method limit through
   * to the output jar uninstrumented, instead of failing the action.
   */
  private static final String SKIP_OVERSIZED_METHODS_FLAG = "--skip_oversized_methods";

  public static void main(String[] args) throws Exception {
    Worker.workerMain(args, new JacocoInstrumenter());
  }

  @Override
  public void work(String[] args) throws Exception {
    Instrumenter jacoco = new Instrumenter(new OfflineInstrumentationAccessGenerator());
    processArg(jacoco, args);
  }

  private void processArg(Instrumenter jacoco, String[] args) throws Exception {
    boolean skipOversizedMethods = false;
    int firstPositional = 0;

    while (firstPositional < args.length && args[firstPositional].startsWith("--")) {
      String flag = args[firstPositional++];
      if (SKIP_OVERSIZED_METHODS_FLAG.equals(flag)) {
        skipOversizedMethods = true;
      } else {
        throw new Exception("unknown flag `" + flag + "` in arguments: " + Arrays.asList(args));
      }
    }

    if (args.length - firstPositional < 3) {
      throw new Exception(
          "expected format `[flags] in_path out_path src1 src2 ... srcN`  for arguments: "
              + Arrays.asList(args));
    }

    Path inPath = Paths.get(args[firstPositional]);
    Path outPath = Paths.get(args[firstPositional + 1]);
    String[] srcs = Arrays.copyOfRange(args, firstPositional + 2, args.length);

    // Use a directory for coverage metadata that is unique to each built jar. Avoids
    // multiple threads performing read/write/delete actions on the instrumented classes directory.
    Path instrumentedClassesDirectory = getMetadataDirRelativeToJar(outPath);
    Files.createDirectories(instrumentedClassesDirectory);

    JarCreator jarCreator = new JarCreator(outPath);

    try (FileSystem inFS = FileSystems.newFileSystem(inPath, (ClassLoader) null)) {
      FileVisitor fileVisitor =
          createInstrumenterVisitor(
              jacoco, instrumentedClassesDirectory, jarCreator, skipOversizedMethods);
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
          String.join("\n", srcs).getBytes(java.nio.charset.StandardCharsets.UTF_8));

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
   * Whether an instrumentation failure was ASM refusing to write a method over the JVM's 64KB
   * limit. ASM's {@code MethodTooLargeException} is repackaged into the jarjar'd JaCoCo runner, so
   * it isn't on this tool's compile classpath and can't be caught by type.
   */
  private static boolean isMethodTooLarge(Throwable t) {
    for (Throwable cause = t; cause != null; cause = cause.getCause()) {
      if (cause.getClass().getSimpleName().equals("MethodTooLargeException")) {
        return true;
      }
      if (cause.getCause() == cause) {
        break;
      }
    }
    return false;
  }

  private SimpleFileVisitor createInstrumenterVisitor(
      Instrumenter jacoco,
      Path instrumentedClassesDirectory,
      JarCreator jarCreator,
      boolean skipOversizedMethods) {
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
          } catch (final IOException e) {
            if (!skipOversizedMethods || !isMethodTooLarge(e)) {
              throw e;
            }
            // JaCoCo's probes push a method that is already near the JVM's 64KB limit over it.
            // Failing here would fail the build of a library that compiles and tests fine, and
            // take every test that depends on it down with it, so pass the class through
            // untouched instead. Skipping its `.uninstrumented` twin keeps the class out of the
            // report entirely rather than reporting it as uncovered.
            System.err.println(
                "JacocoInstrumenter: skipping "
                    + inPath
                    + " (instrumented method exceeds the 64KB JVM limit); it will be absent from"
                    + " coverage reports");
            Files.deleteIfExists(tempPath);
            jarCreator.addEntry(inPath.toString(), inPath);
            return FileVisitResult.CONTINUE;
          }
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
