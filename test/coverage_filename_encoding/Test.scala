package coverage_filename_encoding

import org.specs2.mutable.SpecificationWithJUnit

class Test extends SpecificationWithJUnit {
  "testA1" in {
    A1.a1(true) must be_!=(1)
  }
}
