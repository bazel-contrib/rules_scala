package com.example.coverage.aliasing

import org.scalatest.flatspec._

class TestSameBasenameMapping extends AnyFlatSpec {

  "one.Same, path mirrors package" should "keep its own coverage" in {
    assert(com.example.coverage.aliasing.one.Same.coveredOne(1) == 2)
  }

  "two.Same, path mirrors package" should "keep its own coverage" in {
    assert(com.example.coverage.aliasing.two.Same.coveredTwo(1) == 3)
  }
}
