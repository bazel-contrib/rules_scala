object KindProjector {
  trait Functor[F[_]]
  val either: Functor[Either[Int, *]] = new Functor[Either[Int, *]] {}
}
