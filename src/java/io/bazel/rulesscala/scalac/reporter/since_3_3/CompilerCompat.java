package io.bazel.rulesscala.scalac.reporter;

import dotty.tools.dotc.core.Contexts;
import dotty.tools.dotc.reporting.Message;
import dotty.tools.dotc.reporting.NoExplanation;

public class CompilerCompat {
  static Message toMessage(String msg) {
    return new NoExplanation((ctx) -> msg, Contexts.NoContext());
  }
}
