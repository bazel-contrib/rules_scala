package io.bazel.rulesscala.sourcecompat

object SourceCompat {
  type Class = java.lang.Class[_]
  type ClassOf[+Upper] = java.lang.Class[_ <: Upper]

  type Stream[+T] = scala.Stream[T]
  val Stream: scala.Stream.type = scala.Stream

  def toStream[A](it: Iterable[A]): Stream[A] = it.toStream

  val JavaConversions = scala.collection.JavaConverters
}
