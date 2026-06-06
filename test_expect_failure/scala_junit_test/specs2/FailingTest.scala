package scalarules.test.junit.specs2

import org.specs2.mutable.SpecificationWithJUnit

class FailingTest extends SpecificationWithJUnit {

  val boom: String = { throw new Exception("Boom") }

  "some test" >> { boom must beEmpty }
}
