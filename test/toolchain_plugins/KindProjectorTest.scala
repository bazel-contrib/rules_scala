package test.toolchain_plugins

object KindProjectorTest {
  // This WILL NOT compile without kind-projector plugin
  def foo[F[_], A](fa: F[A]): F[Tuple2[A, ?]] = ???
}