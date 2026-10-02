package coverage_jacoco_runtime

import scala.quoted.*

object MacroScala3 {
  inline def twice(inline i: Int): Int = ${ twiceImpl('i) }

  def twiceImpl(i: Expr[Int])(using Quotes): Expr[Int] = Expr(Helper.twice(i.valueOrAbort))
}
