package coverage_oversized_method

import org.scalatest.flatspec._

class TestOversizedMethod extends AnyFlatSpec {
  "OversizedMethod" should "still be callable when coverage skips instrumenting it" in {
    assert(new OversizedMethod().count(true) == 4000)
  }

  "SmallClass" should "be instrumented as usual" in {
    assert(new SmallClass().twice(21) == 42)
  }
}
