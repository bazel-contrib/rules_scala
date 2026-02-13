package examples.native

import scala.scalanative.unsafe._
import scala.scalanative.unsigned._

@extern object stdlib:
  def malloc(size: CSize): Ptr[Byte] = extern

val ptr = stdlib.malloc(32.toCSize)