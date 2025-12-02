package io.bazel.rulesscala.scalac.reporter;

import dotty.tools.dotc.core.Contexts;
import dotty.tools.dotc.reporting.Message;
import dotty.tools.dotc.reporting.NoExplanation;

public class CompilerCompat {
  static Message toMessage(String msg) {
    return new NoExplanation(() -> msg);
  }
  
  static boolean isWarningFatal(Contexts.Context ctx) {
    return (boolean) ctx.settings().XfatalWarnings().valueIn(ctx.settingsState());
  }
}
