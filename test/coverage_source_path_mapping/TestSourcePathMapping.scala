package com.example.coverage.mapping

import com.example.coverage.other.AlsoMapped
import org.scalatest.flatspec._

class TestSourcePathMapping extends AnyFlatSpec {

  "Mapped, deeper package than directory" should "be covered" in {
    assert(Mapped.covered("ab") == "ba")
  }

  "AlsoMapped, deeper package than directory" should "be covered" in {
    assert(AlsoMapped.covered(1) == 2)
  }
}
