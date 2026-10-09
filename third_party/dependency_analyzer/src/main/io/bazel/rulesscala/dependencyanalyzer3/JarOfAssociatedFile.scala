package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.io.AbstractFile

/** The jar that contains a class or tasty file, or the file itself.
  *
  * Scala 3.0 through 3.9 expose that jar as `AbstractFile.underlyingSource`.
  */
object JarOfAssociatedFile:
  def apply(file: AbstractFile): AbstractFile =
    file.underlyingSource.getOrElse(file)
