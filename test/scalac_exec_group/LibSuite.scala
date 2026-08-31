package scalarules.test.scalac_exec_group

import org.scalatest.flatspec._

class LibSuite extends AnyFlatSpec {
  "Lib" should "have a message" in {
    assert(Lib.message.nonEmpty)
  }
}
