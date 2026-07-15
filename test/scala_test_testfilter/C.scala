import org.scalatest.funsuite.AnyFunSuite

class C extends AnyFunSuite {

  test("test 1") {

  }

  test("test 2") {
    fail("method test 2 should be excluded")
  }

}
