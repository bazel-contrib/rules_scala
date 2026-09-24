package coverage_jacoco_runtime

import scala.language.experimental.macros
import scala.reflect.macros.blackbox

object Macro {
  def twice(i: Int): Int = macro twiceImpl

  def twiceImpl(c: blackbox.Context)(i: c.Expr[Int]): c.Expr[Int] = {
    import c.universe._
    val Literal(Constant(value: Int)) = i.tree
    c.Expr[Int](Literal(Constant(Helper.twice(value))))
  }
}
