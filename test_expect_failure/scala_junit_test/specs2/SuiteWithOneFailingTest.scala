package scalarules.test.junit.specs2

import org.specs2.mutable.SpecificationWithJUnit

class SuiteWithOneFailingTest extends SpecificationWithJUnit {

  "specs2 tests" >> {
    "succeed" >> success
    "fail" >> failure("boom")
  }

  "some other suite" >> {
    "do stuff" >> success
  }
}
