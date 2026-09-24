package coverage_jacoco_runtime

import org.scalatest.funsuite.AnyFunSuite

class JacocoRuntimeScala3Test extends AnyFunSuite {
  test("macro expands at compile time") {
    assert(UserScala3.answer == 42)
  }
}
