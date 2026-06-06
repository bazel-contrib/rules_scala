package scalarules.test

import scala.quoted.*

object MacroTest {
  inline def hello(param: Any): Unit = ${ helloImpl('param) }

  private def helloImpl(param: Expr[Any])(using Quotes): Expr[Unit] = {
    val paramRep = param.show
    '{ println(${ Expr(paramRep) } + " = " + $param) }
  }
}
