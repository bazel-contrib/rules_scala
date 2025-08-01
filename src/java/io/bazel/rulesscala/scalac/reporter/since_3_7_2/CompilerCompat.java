package io.bazel.rulesscala.scalac.reporter;

import dotty.tools.dotc.core.Contexts;
import dotty.tools.dotc.reporting.Message;
import dotty.tools.dotc.reporting.NoExplanation;
import scala.collection.immutable.List$;

public class CompilerCompat {
  static Message toMessage(String msg) {
        return new NoExplanation(
            ctx -> msg,            // msgFn   : Context ⇒ String
            List$.MODULE$.empty(), // actions : List[CodeAction] (= List.empty), added in 3.7.2
            Contexts.NoContext()   // using   : Context, added in 3.3.0
    );
  }
}
