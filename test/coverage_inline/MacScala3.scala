package coverage_inline

import scala.quoted.*

object Mac {
  inline def twice(inline i: Int): Int = ${ twiceImpl('i) }

  def twiceImpl(i: Expr[Int])(using Quotes): Expr[Int] = Expr(Lib.twice(i.valueOrAbort))
}
