package example

import com.google.common.base.Joiner

object Greeter {
  def main(args: Array[String]): Unit =
    println(Joiner.on(", ").join("Hello", "world"))
}
