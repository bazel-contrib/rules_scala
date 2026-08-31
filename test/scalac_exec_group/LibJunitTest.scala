package scalarules.test.scalac_exec_group

import org.junit.Assert.assertTrue
import org.junit.Test

class LibJunitTest {

  @Test
  def libHasMessage(): Unit = {
    assertTrue(Lib.message.nonEmpty)
  }
}
