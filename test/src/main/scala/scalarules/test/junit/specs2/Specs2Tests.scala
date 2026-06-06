package scalarules.test.junit.specs2

import org.specs2.mutable.SpecificationWithJUnit
import scalarules.test.junit.support.JUnitCompileTimeDep

class JunitSpecs2Test extends SpecificationWithJUnit {

  "specs2 tests" >> {
    "run smoothly in bazel" in {
      println(JUnitCompileTimeDep.hello)
      success
    }

    "not run smoothly in bazel" in {
      success
    }
  }
}

class JunitSpecs2AnotherTest extends SpecificationWithJUnit {

  "other specs2 tests" >> {
    "run from another test" >> {
      println(JUnitCompileTimeDep.hello)
      success
    }

    "run from another test 2" >> {
      success
    }
  }

  "unrelated test" >> {
    "not run" in {
      success
    }
  }
}

class JunitSpec2RegexTest extends SpecificationWithJUnit {

  "tests with unsafe characters" >> {
    "2 + 2 != 5" in {
      2 + 2 must be_!=(5)
    }

    "work escaped (with regex)" in {
      success
    }
  }
}

class JunitSpecs2ManyFragmentsTest extends SpecificationWithJUnit {

  (1 to 200) foreach { i =>
    s"fragment no $i" in success
  }

}
