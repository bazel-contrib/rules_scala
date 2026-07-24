// Same source as User.scala. The associated Bazel target intentionally
// omits the dep that provides the given, so compilation must fail with
// a "no given instance" error. This anchors the assumption made by the
// `:user` target above: that the given dep really is required.
import given_imports.givenpkg.given

object UserMissingGivenDep:
  val tc: given_imports.tcpkg.TC[Int] = summon[given_imports.tcpkg.TC[Int]]
