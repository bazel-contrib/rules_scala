package com.example.coverage.mapping

object Mapped {
  def covered(input: String): String =
    input.reverse

  def uncovered(input: String): String =
    input.toUpperCase
}
