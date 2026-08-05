// Imports a top-level `given` from a package and resolves it via
// `summon`. The associated Bazel target depends on the jar that
// provides the given; building it under `unused_dependency_checker_mode
// = "error"` should succeed, since the given is genuinely required.
//
// This is an end-to-end smoke test. In this minimal setup both the AST
// traversal and the SymbolLoaders.complete DT hook independently catch
// the given's jar, so the test passes regardless of the AST-side change
// in AstUsedJarFinder.scala. The AST path is exercised directly (with
// the DT hook out of the picture) by the unit tests in
// AstUsedJarFinderTest.scala.
import given_imports.givenpkg.given

object User:
  val tc: given_imports.tcpkg.TC[Int] = summon[given_imports.tcpkg.TC[Int]]
