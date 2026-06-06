package scalarules.test.location_expansion

import org.specs2.mutable.SpecificationWithJUnit
class LocationExpansionTest extends SpecificationWithJUnit {

  "tests" >> {
    "support location expansion" >> {
      sys.props.get("location.expanded") must beSome(contain("worker"))

    }
  }
  

}
