package io.bazel.rulesscala.sourcecompat

object SourceCompat {
  type Class = java.lang.Class[_]
  type ClassOf[+Upper] = java.lang.Class[_ <: Upper]

  type Stream[+T] = scala.LazyList[T]
  val Stream: scala.LazyList.type = scala.LazyList

  def toStream[A](it: Iterable[A]): Stream[A] = it.to(LazyList)

  val JavaConversions = scala.jdk.CollectionConverters
}
