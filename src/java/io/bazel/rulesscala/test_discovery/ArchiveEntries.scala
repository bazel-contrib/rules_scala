package io.bazel.rulesscala.test_discovery

import io.bazel.rulesscala.sourcecompat.SourceCompat

import java.io.{File, FileInputStream}
import java.util.jar.{JarEntry, JarInputStream}

object ArchiveEntries {
  def listClassFiles(file: File): SourceCompat.Stream[String] = {

    val allEntries = if (file.isDirectory)
      directoryEntries(file).map(_.stripPrefix(file.toString).stripPrefix("/").stripPrefix("\\"))
    else
      jarEntries(new JarInputStream(new FileInputStream(file)))

    allEntries.filter(_.endsWith(".class"))
  }

  private def getJarEntryOrCloseStream(jarInputStream: JarInputStream): Option[JarEntry] = {
    val entry = Option(jarInputStream.getNextJarEntry)

    if (entry.isEmpty)
      jarInputStream.close()

    entry
  }

  private def jarEntries(jarInputStream: JarInputStream): SourceCompat.Stream[String] =
    SourceCompat.Stream.continually(getJarEntryOrCloseStream(jarInputStream))
      .takeWhile(_.nonEmpty)
      .flatten
      .map(_.getName)

  private def directoryEntries(file: File): SourceCompat.Stream[String] =
    SourceCompat.Stream.cons(
      file.toString,
      file.listFiles match {
        case null => SourceCompat.Stream.empty
        case files => SourceCompat.toStream(files).flatMap(directoryEntries)
      }
    )
}
