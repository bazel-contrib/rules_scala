package coverage_inline

object MacroApp {
  def four: Int = Lib.twice(Mac.twice(1))
}
