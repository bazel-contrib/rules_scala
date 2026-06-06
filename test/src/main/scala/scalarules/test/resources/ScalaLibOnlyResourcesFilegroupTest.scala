package scalarules.test.resources

import org.specs2.mutable.SpecificationWithJUnit

class ScalaLibOnlyResourcesFilegroupTest extends SpecificationWithJUnit {

  "Scala library with no srcs and only filegroup resources" >> {
    "allow to load resources" >> {
      get("/resource.txt") must beEqualTo("I am a text resource!")
      get("/subdir/resource.txt") must beEqualTo("I am a text resource in a subdir!")
    }
  }

  private def get(s: String): String =
    scala.io.Source.fromInputStream(getClass.getResourceAsStream(s)).mkString

}

