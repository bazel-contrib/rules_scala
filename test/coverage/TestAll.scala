package coverage;
import org.scalatest._

class TestAll extends FlatSpec {

  "testA1" should "work" in {
    assert(A1.a1(true) == B1)
  }

  "testA2" should "work" in {
    A2.a2()
  }

  "testD1" should "work" in {
    D1.veryLongFunctionNameIsHereAaaaaaaaa()
  }
}
