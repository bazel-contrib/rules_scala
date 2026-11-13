package io.bazel.rulesscala.scaladoc;

import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * Runs Scala 2 Scaladoc.
 *
 * <p>The only argument is {@code @<file>}, with one argument on each line. Scaladoc reads an
 * {@code @<file>} with different rules: it splits each line on whitespace and ignores the text
 * after {@code #}.
 */
public class Scala2ScaladocRunner {
  public static void main(String[] args) throws Exception {
    if (args.length != 1 || !args[0].startsWith("@")) {
      throw new IllegalArgumentException("Usage: Scala2ScaladocRunner @<file>");
    }
    String[] scaladocArgs =
        Files.readAllLines(Paths.get(args[0].substring(1))).toArray(new String[0]);
    Class.forName("scala.tools.nsc.ScalaDoc")
        .getMethod("main", String[].class)
        .invoke(null, (Object) scaladocArgs);
  }
}
