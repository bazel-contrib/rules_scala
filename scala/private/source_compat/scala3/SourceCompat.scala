package io.bazel.rulesscala.sourcecompat

object SourceCompat {
  type Class = java.lang.Class[?]
  type ClassOf[+Upper] = java.lang.Class[? <: Upper]
}
