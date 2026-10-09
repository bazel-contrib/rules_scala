package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.io.AbstractFile

/** The jar that contains a class or tasty file, or the file itself.
  *
  * Scala 3.10 removed `AbstractFile.underlyingSource`. Classpath entries
  * loaded from a jar expose that archive through `enclosing`.
  */
object JarOfAssociatedFile:
  def apply(file: AbstractFile): AbstractFile =
    file.enclosing.getOrElse(file)
