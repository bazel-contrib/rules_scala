package coverage_inline

object CheckedApp {
  def checked(i: Int): Int = {
    Check.positive(i)
    i
  }
}
