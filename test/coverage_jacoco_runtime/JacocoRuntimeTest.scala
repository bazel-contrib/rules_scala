package coverage_jacoco_runtime

import java.nio.file.Paths
import org.scalatest.funsuite.AnyFunSuite

class JacocoRuntimeTest extends AnyFunSuite {
  test("macro expands at compile time") {
    assert(User.answer == 42)
  }

  test("binary runs") {
    val bin = Paths.get(sys.env("TEST_SRCDIR"), sys.env("TEST_WORKSPACE"), "test/coverage_jacoco_runtime/bin")
    val process = new ProcessBuilder(bin.toString).inheritIO().start()
    assert(process.waitFor() == 0)
  }
}
