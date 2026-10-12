package coverage_jacoco_runtime

import java.nio.file.Paths
import org.scalatest.funsuite.AnyFunSuite

class JacocoRuntimeTest extends AnyFunSuite {
  test("macro expands at compile time") {
    assert(User.answer == 42)
  }

  test("binary exits with code 0") {
    val bin = Paths.get(sys.env("TEST_SRCDIR"), sys.env("TEST_WORKSPACE"), "test/coverage_jacoco_runtime/bin")
    val process = new ProcessBuilder(bin.toString).inheritIO().start()
    assert(process.waitFor() == 0)
  }

  test("library deploy jar exits with code 0") {
    val java = Paths.get(sys.props("java.home"), "bin", "java")
    val jar = Paths.get(
      sys.env("TEST_SRCDIR"),
      sys.env("TEST_WORKSPACE"),
      "test/coverage_jacoco_runtime/library_with_main_deploy.jar"
    )
    val process = new ProcessBuilder(java.toString, "-Djacoco-agent.output=none", "-jar", jar.toString).inheritIO().start()
    assert(process.waitFor() == 0)
  }
}
