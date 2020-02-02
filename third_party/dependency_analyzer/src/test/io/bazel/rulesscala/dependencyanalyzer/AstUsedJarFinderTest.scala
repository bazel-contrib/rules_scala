package third_party.dependency_analyzer.src.test.io.bazel.rulesscala.dependencyanalyzer

import java.nio.file.Files
import java.nio.file.Path
import org.apache.commons.io.FileUtils
import org.scalatest._
import third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod
import third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer.ScalaVersion
import third_party.utils.src.test.io.bazel.rulesscala.utils.JavaCompileUtil
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil
import third_party.utils.src.test.io.bazel.rulesscala.utils.TestUtil.DependencyAnalyzerTestParams

class AstUsedJarFinderTest extends FunSuite {
  private def withSandbox(action: Sandbox => Unit): Unit = {
    val tmpDir = Files.createTempDirectory("dependency_analyzer_test_temp")
    val file = tmpDir.toFile
    try {
      action(new Sandbox(tmpDir))
    } finally {
      FileUtils.deleteDirectory(file)
    }
  }

  private class Sandbox(tmpDir: Path) {
    def compileWithoutAnalyzer(
      code: String
    ): Unit = {
      TestUtil.runCompiler(
        code = code,
        extraClasspath = List(tmpDir.toString),
        outputPathOpt = Some(tmpDir)
      )
    }

    def compileJava(
      className: String,
      code: String
    ): Unit = {
      JavaCompileUtil.compile(
        tmpDir = tmpDir.toString,
        className = className,
        code = code
      )
    }

    def checkStrictDepsErrorsReported(
      code: String,
      expectedStrictDeps: List[String]
    ): Unit = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          dependencyAnalyzerParamsOpt =
            Some(
              DependencyAnalyzerTestParams(
                indirectJars = expectedStrictDeps.map(name => tmpDir.resolve(s"$name.class").toString),
                indirectTargets = expectedStrictDeps,
                strictDeps = true,
                dependencyTrackingMethod = DependencyTrackingMethod.Ast
              )
            )
        )

      assert(errors.size == expectedStrictDeps.size)

      expectedStrictDeps.foreach { dep =>
        val expectedError = s"Target '$dep' is used but isn't explicitly declared, please add it to the deps"
        assert(errors.exists(_.contains(expectedError)))
      }
    }

    def checkUnusedDepsErrorReported(
      code: String,
      expectedUnusedDeps: List[String]
    ): Unit = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          dependencyAnalyzerParamsOpt =
            Some(
              DependencyAnalyzerTestParams(
                directJars = expectedUnusedDeps.map(name => tmpDir.resolve(s"$name.class").toString),
                directTargets = expectedUnusedDeps,
                unusedDeps = true,
                dependencyTrackingMethod = DependencyTrackingMethod.Ast
              )
            )
        )

      assert(errors.size == expectedUnusedDeps.size)

      expectedUnusedDeps.foreach { dep =>
        val expectedError = s"Target '$dep' is specified as a dependency to ${TestUtil.defaultTarget} but isn't used, please remove it from the deps."
        assert(errors.exists(_.contains(expectedError)))
      }
    }
  }

  /**
   * In a situation where B depends on A directly, ensure that the
   * dependency analyzer recognizes this fact.
   */
  private def checkDirectDependencyRecognized(
    aCode: String,
    bCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.checkStrictDepsErrorsReported(
        code = bCode,
        expectedStrictDeps = List("A")
      )
    }
  }

  /**
   * In a situation where C depends on both A and B directly, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkDirectDependencyRecognized(
    aCode: String,
    bCode: String,
    cCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.compileWithoutAnalyzer(bCode)
      sandbox.checkStrictDepsErrorsReported(
        code = cCode,
        expectedStrictDeps = List("A", "B")
      )
    }
  }

  /**
   * In a situation where C depends directly on B but not on A, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkIndirectDependencyDetected(
    aCode: String,
    bCode: String,
    cCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.compileWithoutAnalyzer(bCode)
      sandbox.checkUnusedDepsErrorReported(
        code = cCode,
        expectedUnusedDeps = List("A")
      )
    }
  }

  /**
   * In a situation where B depends indirectly on A, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkIndirectDependencyDetected(
    aCode: String,
    bCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.checkUnusedDepsErrorReported(
        code = bCode,
        expectedUnusedDeps = List("A")
      )
    }
  }

  test("simple composition in indirect") {
    checkIndirectDependencyDetected(
      aCode =
        """
          |class A
          |""".stripMargin,
      bCode =
        """
          |class B(a: A)
          |""".stripMargin,
      cCode =
        """
          |class C(b: B)
          |""".stripMargin
    )
  }

  test("method call argument is direct") {
    checkDirectDependencyRecognized(
      aCode =
        """
          |class A
          |""".stripMargin,
      bCode =
        """
          |class B {
          |  def foo(a: A = new A()): Unit = {}
          |}
          |""".stripMargin,
      cCode =
        """
          |class C {
          |  def bar(): Unit = {
          |    new B().foo(new A())
          |  }
          |}
          |""".stripMargin
    )
  }

  test("class ctor arg type parameter is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B(
           |  a: Option[A]
           |)
           |""".stripMargin
    )
  }

  test("class static annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |) extends scala.annotation.StaticAnnotation
           |""".stripMargin,
      bCode =
        s"""
           |@A
           |class B(
           |)
           |""".stripMargin
    )
  }

  test("class annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |@A
           |class B(
           |)
           |""".stripMargin
    )
  }

  test("method annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B {
           |  @A
           |  def foo(): Unit = {
           |  }
           |}
           |""".stripMargin
    )
  }

  test("class type parameter bound is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B[T <: A](
           |)
           |""".stripMargin
    )
  }

  test("classOf is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B(
           |) {
           |  val x: Class[_] = classOf[A]
           |}
           |""".stripMargin
    )
  }

  test("classOf in class annotation is direct") {
    checkDirectDependencyRecognized(
      aCode = "class A",
      bCode = "class B(a: Any)",
      cCode =
        s"""
           |@B(classOf[A])
           |class C
           |""".stripMargin
    )
  }

  test("inlined literal is direct") {
    // Note: For a constant to be inlined
    // - it must not have a type declaration such as `: Int`.
    //   (this appears to be the case in practice at least)
    //   (is this documented anywhere???)
    // - some claim it must start with a capital letter, though
    //   this does not seem to be the case. Nevertheless we do that
    //    anyways.
    //
    // Hence it is possible that as newer versions of scala
    // are released then this test may need to be updated to
    // conform to changing requirements of what is inlined.

    // Note that in versions of scala < 2.12.4 we cannot detect
    // such a situation. Hence we will have a false positive here
    // for those older versions, which we verify in test.

    val aCode =
      s"""
         |object A {
         |  final val Inlined = 123
         |}
         |""".stripMargin
    val bCode =
      s"""
         |object B {
         |  val d: Int = A.Inlined
         |}
         |""".stripMargin

    if (ScalaVersion.Current >= ScalaVersion("2.12.4")) {
      checkDirectDependencyRecognized(aCode = aCode, bCode = bCode)
    } else {
      checkIndirectDependencyDetected(aCode = aCode, bCode = bCode)
    }
  }

  test("java interface method argument is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "B",
        code = "public interface B { }"
      )
      sandbox.checkStrictDepsErrorsReported(
        """
          |class C {
          |  def foo(x: B): Unit = {}
          |}
          |""".stripMargin,
        expectedStrictDeps = List("B")
      )
    }
  }

  test("java interface field and method is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "A",
        code = "public interface A { int a = 42; }"
      )
      val bCode =
        """
          |class B {
          |  def foo(x: A): Unit = {}
          |  val b = A.a
          |}
          |""".stripMargin

      // It is unclear why this only works with these versions but
      // presumably there were various compiler improvements.
      if (ScalaVersion.Current >= ScalaVersion("2.12.0")) {
        sandbox.checkStrictDepsErrorsReported(
          bCode,
          expectedStrictDeps = List("A")
        )
      } else {
        sandbox.checkUnusedDepsErrorReported(
          bCode,
          expectedUnusedDeps = List("A")
        )
      }
    }
  }

  test("java interface field is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "A",
        code = "public interface A { int a = 42; }"
      )
      val bCode =
        """
          |class B {
          |  val b = A.a
          |}
          |""".stripMargin
      if (ScalaVersion.Current >= ScalaVersion("2.12.4")) {
        sandbox.checkStrictDepsErrorsReported(
          bCode,
          expectedStrictDeps = List("A")
        )
      } else {
        sandbox.checkUnusedDepsErrorReported(
          bCode,
          expectedUnusedDeps = List("A")
        )
      }
    }
  }
}
