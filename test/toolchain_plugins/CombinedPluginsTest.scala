package test.toolchain_plugins

// This test uses kind-projector plugin features from toolchain
// AND additional features from the explicitly added plugin
object CombinedPluginsTest {
  // Lambda syntax from kind-projector (global plugin)
  type Tuple2K[F[_]] = Lambda[A => (A, A)]

  // This would also use features from the additional plugin if available
  def test(): Unit = {
    println("Combined plugins test compiled successfully")
  }
}