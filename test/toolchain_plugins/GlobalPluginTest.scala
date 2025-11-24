package test.toolchain_plugins

// This test uses kind-projector plugin features that should be available globally via the toolchain
object GlobalPluginTest {
  // Using * as a type wildcard (kind-projector feature for Scala 2.12)
  type EitherStr[A] = Either[String, A]

  // Test that we can use higher-kinded types
  def foo[F[_]](fa: F[Int]): F[Int] = fa

  def test(): Unit = {
    println("Global plugin test compiled successfully")
    val either: EitherStr[Int] = Right(42)
    println(s"Test value: $either")
  }
}