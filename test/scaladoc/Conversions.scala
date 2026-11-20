package scaladoc

object Conversions {
  implicit def intToString(i: Int): String = i.toString
}
