package coverage_inline

object Lib {
  @inline final def twice(i: Int): Int = i * 2
}
