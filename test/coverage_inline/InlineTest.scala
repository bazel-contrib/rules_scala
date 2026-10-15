package coverage_inline

import org.scalatest.funsuite.AnyFunSuite

class InlineTest extends AnyFunSuite {
  test("inlined call") {
    assert(App.four == 4)
  }
}
