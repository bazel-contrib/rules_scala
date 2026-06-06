package coverage_specs2_with_junit

import org.specs2.mutable.SpecificationWithJUnit

class TestWithSpecs2WithJUnit extends SpecificationWithJUnit {
  "testA1" in {
    A1.a1(true) must be_==(B1)
  }

  "testA2" in {
    A2.a2()
    success
  }

  "testD1" in {
    D1.veryLongFunctionNameIsHereAaaaaaaaa()
    success
  }

  "testE1" in {
    E1.e1("test")
    success
  }
}
