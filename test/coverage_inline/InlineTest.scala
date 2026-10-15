package coverage_inline

import org.scalatest.funsuite.AnyFunSuite

class InlineTest extends AnyFunSuite {
  test("inlined call") {
    assert(App.four == 4)
  }

  test("inlined call next to a macro") {
    assert(MacroApp.four == 4)
  }
}
