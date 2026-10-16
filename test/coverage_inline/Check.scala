package coverage_inline

object Check {
  @inline final def positive(i: Int): Unit =
    if (i <= 0) throw new IllegalArgumentException(s"$i is not positive")
}
