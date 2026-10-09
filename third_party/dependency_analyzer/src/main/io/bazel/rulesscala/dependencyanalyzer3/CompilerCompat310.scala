package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.io.{AbstractFile, virtualDirectory}

object CompilerCompat {
  def jarOfAssociatedFile(file: AbstractFile): AbstractFile =
    file.enclosing.getOrElse(file)

  def inMemoryOutput(name: String): AbstractFile =
    virtualDirectory(name)
}
