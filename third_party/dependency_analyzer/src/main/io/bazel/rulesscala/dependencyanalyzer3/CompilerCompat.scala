package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.io.{AbstractFile, VirtualDirectory}

object CompilerCompat {
  def jarOfAssociatedFile(file: AbstractFile): AbstractFile =
    file.underlyingSource.getOrElse(file)

  def inMemoryOutput(name: String): AbstractFile =
    new VirtualDirectory(name)
}
