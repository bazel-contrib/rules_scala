"""Serializes the actions a target would run, so they can key a nested test.

A nested `bazel build` is opaque to the outer Bazel, so a change in the rules
that alters how the fixture is built does not invalidate the test that drives
it. The command lines do change, though, and an aspect can read them: writing
them to a file and declaring that file as a test input makes the test re-run
exactly when the fixture's build actually changed.

The fixture is analysed under the toolchains the nested `bazel` registers, so a
change in one of those lands in the command lines too.

Command lines carry output paths, and those name the configuration they were
built in, so the fingerprint would otherwise differ under every flag the outer
build happens to set and re-run the test for nothing. The configuration segment
is dropped, in the spirit of Bazel's own path mapping. What is left out: actions
that write a file rather than run a command line (`ctx.actions.write`, template
expansion) contribute their mnemonic and nothing else, so a change to what such
an action writes does not reach the fingerprint.
"""

_ActionsInfo = provider(fields = ["lines"])

def _without_configuration(line):
    # Output paths carry the configuration (`bazel-out/k8-fastbuild-ST-1234/`),
    # so the same fixture yields a different fingerprint under every flag the
    # outer build happens to set, and every such build re-runs the test. The
    # nested `bazel` does not inherit those flags, so drop the segment.
    parts = line.split("bazel-out/")
    out = parts[0]
    for part in parts[1:]:
        slash = part.find("/")
        out += "bazel-out/" + ("<cfg>" + part[slash:] if slash != -1 else part)
    return out

def _collect_impl(target, ctx):
    # One line per action, keeping the arguments in order. Collecting the tokens
    # separately would lose which value belongs to which flag: a depset of tokens
    # does not change when a flag's value is swapped for one that some other flag
    # already carries, and `unused_dependency_checker_mode = "error"` -> `"off"`
    # is exactly that.
    direct = []
    for action in target.actions:
        argv = getattr(action, "argv", None) or []
        direct.append(_without_configuration(" ".join([action.mnemonic] + argv)))

    # A fixture may compile in its dependencies rather than itself (a
    # `scala_library_suite` builds children and only merges their jars), so the
    # command lines that a rules change would alter live one level down.
    transitive = []
    for attr_name in dir(ctx.rule.attr):
        value = getattr(ctx.rule.attr, attr_name, None)
        for dep in (value if type(value) == "list" else [value]):
            if type(dep) == "Target" and _ActionsInfo in dep:
                transitive.append(dep[_ActionsInfo].lines)
    return [_ActionsInfo(lines = depset(direct, transitive = transitive))]

collect_actions_aspect = aspect(
    implementation = _collect_impl,
    attr_aspects = ["*"],
)

def _toolchains_transition_impl(_settings, attr):
    # Analyse the fixture under the toolchains the nested `bazel` will register,
    # so that changing one of them changes the command lines collected above.
    # Whatever the outer build registered is replaced, not extended: the nested
    # `bazel` gets these and nothing else.
    return {"//command_line_option:extra_toolchains": attr.extra_toolchains}

_toolchains_transition = transition(
    implementation = _toolchains_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:extra_toolchains"],
)

def _exposed_impl(ctx):
    out = ctx.actions.declare_file("%s.actions.txt" % ctx.label.name)
    ctx.actions.write(out, content = "\n".join(
        sorted(ctx.attr.target[0][_ActionsInfo].lines.to_list()),
    ) + "\n")
    return [DefaultInfo(files = depset([out]))]

fixture_actions = rule(
    implementation = _exposed_impl,
    attrs = {
        "extra_toolchains": attr.string_list(
            doc = "Toolchains the nested `bazel` registers, to analyse `target` under.",
        ),
        "target": attr.label(aspects = [collect_actions_aspect], cfg = _toolchains_transition),
    },
    doc = "Writes the command lines of `target`'s actions to a file.",
)
