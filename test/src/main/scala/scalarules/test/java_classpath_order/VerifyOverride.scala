package scalarules.test.java_classpath_order

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

/**
 * This test verifies that the Java class (Overridable) shadows
 * the Scala class from the dependency.
 *
 * The expected behavior is:
 * - The Java file compiled in the scala_library with_java_override should
 *   appear first on the classpath
 * - When instantiating Overridable, we should get the Java version
 *   which returns "overridden"
 */
class VerifyOverrideTest extends AnyFlatSpec with Matchers {

  "Java class in scala_library" should "shadow the dependency's class" in {
    val instance = new Overridable()
    val value = instance.getValue()

    value shouldBe "overridden"
  }
}

