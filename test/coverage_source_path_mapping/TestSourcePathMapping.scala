package com.example.coverage.mapping

import com.example.coverage.other.AlsoMapped
import org.scalatest.flatspec._

class TestSourcePathMapping extends AnyFlatSpec {

  "Mapped.covered" should "work" in {
    assert(Mapped.covered("ab") == "ba")
  }

  "AlsoMapped.covered" should "work" in {
    assert(AlsoMapped.covered(1) == 2)
  }
}
