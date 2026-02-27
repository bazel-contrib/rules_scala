package test.toolchain_plugins

import scala.language.higherKinds

// This REQUIRES kind-projector plugin - uses the * syntax
class HKT[F[_]]
class RequiresPlugin extends HKT[Either[String, *]]