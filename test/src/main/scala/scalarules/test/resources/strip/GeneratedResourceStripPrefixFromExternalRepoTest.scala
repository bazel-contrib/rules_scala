package scalarules.test.resources.strip

import org.specs2.mutable.SpecificationWithJUnit

class GeneratedResourceStripPrefixFromExternalRepoTest extends SpecificationWithJUnit {

  "resource_strip_prefix" >> {
    "strip the prefix on a generated resource from an external repo" in {
      val resource = getClass.getResourceAsStream("/nosrc_jar_generated_resource.txt")
      resource must not beNull
    }
  }

}
