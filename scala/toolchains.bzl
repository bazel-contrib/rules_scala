"""Macros to instantiate and register @rules_scala_toolchains"""

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//scala:toolchains_repo.bzl", "scala_toolchains_repo")
load("//scala/private:macros/scala_repositories.bzl", "setup_scala_compiler_sources")
load("//scala/private:toolchain_defaults.bzl", "TOOLCHAIN_DEFAULTS")

_DEFAULT_TOOLCHAINS_REPO_NAME = "rules_scala_toolchains"

_scala_parser_combinators_version = "1.1.2"

def _toolchain_opts(tc_arg):
    """Converts a toolchain parameter to a (bool, dict of options).

    Used by `scala_toolchains` to parse toolchain arguments as True, False,
    None, or a dict of options.

    Args:
        tc_arg: a bool, dict, or None

    Returns:
        a bool indicating whether the toolchain is enabled, and a dict
            containing any provided toolchain options
    """
    if tc_arg == False or tc_arg == None:
        return False, {}
    return True, ({} if tc_arg == True else tc_arg)

def _process_toolchain_options(toolchain_defaults, **kwargs):
    """Checks the validity of toolchain options and provides defaults.

    Updates each toolchain option dictionary with defaults for every missing
    entry.

    Args:
        toolchain_defaults: a dict of `{toolchain_name: default options dict}`
        **kwargs: keyword arguments of the form `toolchain_name = options_dict`

    Returns:
        a list of error messages for invalid toolchains or options
    """
    errors = []

    for tc, options in kwargs.items():
        defaults = toolchain_defaults.get(tc, None)

        if defaults == None:
            errors.append("unknown toolchain or doesn't have defaults: " + tc)
            continue

        unexpected = [a for a in options if a not in defaults]

        if unexpected:
            plural = "s" if len(unexpected) != 1 else ""
            errors.append(
                "unexpected %s toolchain attribute%s: " % (tc, plural) +
                ", ".join(unexpected),
            )

        options.update({
            k: v
            for k, v in defaults.items()
            if k not in options and v != None
        })

    return errors

def scala_toolchains(
        name = _DEFAULT_TOOLCHAINS_REPO_NAME,
        scala_compiler_srcjars = {},
        scala = True,
        scalatest = False,
        junit = False,
        specs2 = False,
        scalafmt = False,
        scala_proto = False,
        jmh = False,
        twitter_scrooge = False):
    """Instantiates rules_scala toolchains and all their dependencies.

    Provides a unified interface to configuring `rules_scala` both directly in a
    `WORKSPACE` file and in a Bazel module extension.

    Instantiates a repository containing all configured toolchains. Under
    `WORKSPACE`, you will need to call `scala_register_toolchains()`. Under
    Bzlmod, the `MODULE.bazel` file from `rules_scala` does this automatically.

    All arguments are optional.

    Args:
        name: Name of the generated toolchains repository
        scala_compiler_srcjars: optional dictionary of Scala version string to
            compiler srcjar metadata dictionaries containing:
            - exactly one "label", "url", or "urls" key
            - optional "integrity" or "sha256" keys
        scala: whether to instantiate default Scala toolchains for configured
            Scala versions
        scalatest: whether to instantiate the ScalaTest toolchain
        junit: whether to instantiate the JUnit toolchain
        specs2: whether to instantiate the Specs2 JUnit toolchain
        scalafmt: boolean or dictionary of Scalafmt options:
            - default_config: default Scalafmt config file target
        scala_proto: boolean or dictionary of `setup_scala_proto_toolchain()`
            options
        jmh: whether to instantiate the Java Microbenchmarks Harness toolchain
        twitter_scrooge: bool or dictionary of `setup_scrooge_toolchain()`
            options
    """
    scalafmt, scalafmt_options = _toolchain_opts(scalafmt)
    scala_proto, scala_proto_options = _toolchain_opts(scala_proto)
    twitter_scrooge, twitter_scrooge_options = _toolchain_opts(twitter_scrooge)

    errors = _process_toolchain_options(
        TOOLCHAIN_DEFAULTS,
        scalafmt = scalafmt_options,
        scala_proto = scala_proto_options,
        twitter_scrooge = twitter_scrooge_options,
    )
    if errors:
        fail("\n".join(errors))

    setup_scala_compiler_sources(scala_compiler_srcjars)

    if specs2:
        junit = True

    # Most external dependencies used by the toolchains are declared in `MODULE.bazel`. Unfortunately, we can't declare
    # the dependencies for the compilation toolchain there, as we don't know which Scala versions will be used (and
    # can't determine that within `MODULE.bazel`). So we fetch them here using `rules_jvm_external`'s repository rule
    # for fetching Maven artifacts: `maven_install`.
    for scala_version in SCALA_VERSIONS:
        maven_install(
            name = "rules_scala_compiler_{}".format(scala_version.replace(".", "_")),
            artifacts = (
                ([
                    "org.scala-lang:scala-compiler:{}".format(scala_version),
                    "org.scala-lang:scala-library:{}".format(scala_version),
                    "org.scala-lang:scala-reflect:{}".format(scala_version),
                    "org.scalameta:semanticdb-scalac_{}:4.9.9".format(scala_version),
                ] if scala_version.startswith("2.") else [
                    "org.scala-lang:scala-library:2.13.16",
                    "org.scala-lang:scala3-compiler_3:{}".format(scala_version),
                    "org.scala-lang:scala3-library_3:{}".format(scala_version),
                    "org.scala-lang:scala3-interfaces:{}".format(scala_version),
                    "org.scala-lang:tasty-core_3:{}".format(scala_version),
                    "org.scala-lang.modules:scala-parser-combinators_2.13:{}".format(_scala_parser_combinators_version),
                    "org.scala-lang.modules:scala-xml_3:2.1.0",
                    "org.scala-sbt:compiler-interface:1.10.8",
                ]) +
                ([
                    "org.scala-lang.modules:scala-parser-combinators_2.11:{}".format(_scala_parser_combinators_version),
                    "org.scala-lang.modules:scala-xml_2.11:1.3.0",
                ] if scala_version.startswith("2.11") else []) +
                ([
                    "org.scala-lang.modules:scala-parser-combinators_2.12:{}".format(_scala_parser_combinators_version),
                    "org.scala-lang.modules:scala-xml_2.12:2.3.0",
                ] if scala_version.startswith("2.12") else []) +
                ([
                    "org.scala-lang.modules:scala-parser-combinators_2.13:{}".format(_scala_parser_combinators_version),
                    "org.scala-lang.modules:scala-xml_2.13:2.1.0",
                ] if scala_version.startswith("2.13") else []) +
                (["org.scala-lang.modules:scala-asm:9.2.0-scala-1"] if scala_version.startswith("3.1") else []) +
                (["org.scala-lang.modules:scala-asm:9.3.0-scala-1"] if scala_version.startswith("3.2") else []) +
                (["org.scala-lang.modules:scala-asm:9.8.0-scala-1"] if scala_version.startswith("3.3") else []) +
                (["org.scala-lang.modules:scala-asm:9.6.0-scala-1"] if scala_version.startswith("3.4") else []) +
                (["org.scala-lang.modules:scala-asm:9.7.0-scala-1"] if scala_version.startswith("3.5") else []) +
                (["org.scala-lang.modules:scala-asm:9.7.1-scala-1"] if scala_version.startswith("3.6") else []) +
                (["org.scala-lang.modules:scala-asm:9.8.0-scala-1"] if scala_version.startswith("3.7") else [])
            ),
            fetch_sources = True,
            repositories = default_maven_server_urls(),
        )

    scala_toolchains_repo(
        name = name,
        scalatest = scalatest,
        junit = junit,
        specs2 = specs2,
        scalafmt = scalafmt,
        scalafmt_default_config = scalafmt_options["default_config"],
        scala_proto = scala_proto,
        scala_proto_options = scala_proto_options["default_gen_opts"],
        jmh = jmh,
        twitter_scrooge = twitter_scrooge,
        # When we _really_ drop Bazel 6 entirely, this attribute can become an
        # attr.string_keyed_label_dict, and this conversion won't be necessary.
        twitter_scrooge_deps = {
            k: str(v)
            for k, v in twitter_scrooge_options.items()
        },
    )

def scala_register_toolchains(name = _DEFAULT_TOOLCHAINS_REPO_NAME):
    native.register_toolchains("@%s//...:all" % name)

def scala_register_unused_deps_toolchains():
    native.register_toolchains(
        "//scala:unused_dependency_checker_error_toolchain",
    )
