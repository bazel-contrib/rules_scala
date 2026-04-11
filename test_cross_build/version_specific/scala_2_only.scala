object Scala2Only {
  implicit class StringOps(val s: String) extends AnyVal {
    def twice: String = s + s
  }
}
