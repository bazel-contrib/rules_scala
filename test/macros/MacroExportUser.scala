package macros

object MacroExportUser {
  def main(arguments: Array[String]): Unit = println(IdentityMacro.identityMacro("Hello via export!"))
}
