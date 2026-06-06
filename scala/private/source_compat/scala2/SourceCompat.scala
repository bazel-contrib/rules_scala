package io.bazel.rulesscala.sourcecompat

object SourceCompat {
  type Class = java.lang.Class[_]
  type ClassOf[+Upper] = java.lang.Class[_ <: Upper]
}
