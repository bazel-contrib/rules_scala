package scalarules.test.scalac_exec_group

import language.experimental.macros

import reflect.macros.whitebox.Context

object Macro {
  def echo(param: Any): Unit = macro echo_impl

  def echo_impl(c: Context)(param: c.Expr[Any]): c.Expr[Unit] = {
    import c.universe._
    reify { println(param.splice) }
  }
}
