package io.bazel.rulesscala.dependencyanalyzer

import org.scalatest.funsuite.AnyFunSuite
import io.bazel.rulesscala.utils.Scala3CompilerUtils

class CompileTest extends AnyFunSuite {

    test("Util compiles valid code") {
        val scalaCode = "class Foo {  }"
        val messages = Scala3CompilerUtils.runCompiler(scalaCode)

        assert(messages.isEmpty, "No messages must be reported when valid code is compiled")
    }

    test("Util returns errors on invalid code") {
        val scalaCode = "!@#"
        val messages = Scala3CompilerUtils.runCompiler(scalaCode)

        assert(
            messages.exists(_.message.contains("Illegal start of toplevel definition")),
            "Error must be reported when valid code is compiled"
        )
    }
}