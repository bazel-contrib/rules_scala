package scalarules.test

import org.scalatest.flatspec._

// Validates that the `run_environment_info` implementation from
// //scala/private:phases/phase_runenvironmentinfo_provider.bzl conforms to:
// - https://bazel.build/rules/lib/providers/RunEnvironmentInfo
class EnvAttributeManualTest extends AnyFlatSpec {
  val env = System.getenv()

  "--test_env variables not in env" should "pass through" in {
    assert(env.get("FROM_TEST_ENV") == "test env value")
  }

  "env_inherit variables not in env" should "pass through" in {
    assert(env.get("FROM_ENV_INHERIT") == "inherited value")
  }

  "variables not in env_inherit" should "not pass through" in {
    assert(env.get("NOT_IN_ENV_INHERIT") == null)
  }

  "env" should "override --test_env" in {
    assert(env.get("FROM_TEST_ENV_AND_ENV_ATTR") == "env attribute value")
  }

  "env_inherit" should "override env" in {
    assert(env.get("FROM_ENV_INHERIT_AND_ENV_ATTR") == "inherited value")
  }

  "env_inherit" should "override --test_env" in {
    assert(env.get("FROM_ENV_INHERIT_AND_TEST_ENV") == "inherited value")
  }

  "env_inherit" should "override --test_env and env when all specified" in {
    assert(env.get("FROM_ALL_SOURCES") == "inherited value")
  }
}
