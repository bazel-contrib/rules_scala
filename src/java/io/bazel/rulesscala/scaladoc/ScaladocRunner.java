package io.bazel.rulesscala.scaladoc;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.List;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * Runs Scala 3 Scaladoc.
 *
 * <p>The only argument is {@code @<file>}, with one argument on each line. The file starts with
 * {@code --tasty_jar=<jar>} lines, and the Scaladoc arguments follow them.
 *
 * <p>Scaladoc reads a jar only together with a {@code .tasty} file input. Thus the runner copies
 * the {@code .tasty} files of each {@code --tasty_jar} into a directory, and gives the
 * directories to Scaladoc.
 */
public class ScaladocRunner {
  private static final String TASTY_JAR_FLAG = "--tasty_jar=";

  public static void main(String[] args) throws Exception {
    if (args.length != 1 || !args[0].startsWith("@")) {
      throw new IllegalArgumentException("Usage: ScaladocRunner @<file>");
    }
    Path tmp = Files.createTempDirectory("scaladoc");
    Runtime.getRuntime().addShutdownHook(new Thread(() -> deleteTree(tmp)));

    // Scaladoc reads static site pages from `-siteroot`, which is `./docs` by default. Without a
    // sandbox, `./docs` is the `docs` directory of the main repository. An empty directory gives
    // only the API pages.
    Path siteRoot = Files.createDirectory(tmp.resolve("siteroot"));
    List<String> scaladocArgs = new ArrayList<>(List.of("-siteroot", siteRoot.toString()));
    List<String> lines = Files.readAllLines(Paths.get(args[0].substring(1)));
    int i = 0;
    for (; i < lines.size(); i++) {
      String line = lines.get(i);
      if (line.startsWith(TASTY_JAR_FLAG)) {
        Path dir = tmp.resolve("tasty").resolve(Integer.toString(i));
        extractTasty(line.substring(TASTY_JAR_FLAG.length()), dir);
        scaladocArgs.add(dir.toString());
      } else {
        break;
      }
    }
    scaladocArgs.addAll(lines.subList(i, lines.size()));

    Class.forName("dotty.tools.scaladoc.Main")
        .getMethod("main", String[].class)
        .invoke(null, (Object) scaladocArgs.toArray(new String[0]));
  }

  private static void extractTasty(String jar, Path dir) throws IOException {
    Files.createDirectories(dir);
    try (ZipFile zip = new ZipFile(jar)) {
      Enumeration<? extends ZipEntry> entries = zip.entries();
      while (entries.hasMoreElements()) {
        ZipEntry entry = entries.nextElement();
        if (entry.isDirectory() || !entry.getName().endsWith(".tasty")) {
          continue;
        }
        Path target = dir.resolve(entry.getName());
        Files.createDirectories(target.getParent());
        try (InputStream in = zip.getInputStream(entry)) {
          Files.copy(in, target);
        }
      }
    }
  }

  private static void deleteTree(Path root) {
    try (Stream<Path> paths = Files.walk(root)) {
      paths.sorted(Comparator.reverseOrder()).forEach(path -> path.toFile().delete());
    } catch (IOException e) {
      // A failed delete leaves files in the temporary directory.
    }
  }
}
