import org.scalatest.funsuite._
import org.scalatest.matchers.should._

class SpacedEnvTest extends AnyFunSuite with Matchers {
  test("value with a space from inherit_env") {
    sys.env("greeting") should equal("hello world")
  }
}
