load("@bazel_tools//tools/cpp:toolchain_utils.bzl",
  "find_cpp_toolchain",
  "use_cpp_toolchain",
)
load(
    "@rules_cc//cc:defs.bzl",
    "cc_common",
)
load(
  "@rules_java//java/common:java_info.bzl",
  "JavaInfo",
)
load(
    "//scala/private:common.bzl",
    "collect_jars",
)
load(
    "//scala:scala_cross_version.bzl",
    "scala_version_transition",
    "toolchain_transition_attr",
)
load(
    "//scala_native:providers.bzl",
    "ScalaNativeInfo",
)

def _scala_native_binary_impl(ctx):
    # Get the Scala Native toolchain
    scala_native_toolchain = ctx.toolchains["//scala_native:toolchain_type"]
    
    # Get C++ toolchain for hermetic clang
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    clang_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = "c-compile",
    )
    clang_pp_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = "c++-compile",
    )

    # Build the list of dependencies including Scala Native runtime libraries
    # Collect native lib jars specifically
    native_libs_jars = []
    for lib in [
        scala_native_toolchain.nativelib,
        scala_native_toolchain.javalib,
        scala_native_toolchain.auxlib,
        scala_native_toolchain.scalalib,
    ]:
         if JavaInfo in lib:
             # Use transitive jars to include scala-library etc. which are deps of scalalib
             native_libs_jars.extend(lib[JavaInfo].transitive_runtime_jars.to_list())
    
    # Collect user deps
    user_deps_jars = []
    for dep in ctx.attr.deps:
        if JavaInfo in dep:
            user_deps_jars.append(dep[JavaInfo].transitive_runtime_jars)
            
    # Construct classpath with native libs FIRST
    # We use order="preorder" to ensure direct items (native libs) come before transitive if possible,
    # or just rely on the fact that we put them in 'direct'.
    # Actually, to be safe with add_joined, we can't easily force order of depset without flattening.
    # But flattening is expensive?
    # For Phase 2, we can flatten 'native_libs_jars' (it's small) and append 'user_deps_jars'.
    # But 'user_deps_jars' is a list of depsets.
    
    # Better: create a depset that puts native libs as direct, and others as transitive.
    # And specify order="preorder" (direct first).
    classpath = depset(direct = native_libs_jars, transitive = user_deps_jars, order = "preorder")
    print("DEBUG: Native Libs Jars:", native_libs_jars, "         ")

    
    main_class = ctx.attr.main_class
    module_name = ctx.label.name
    
    output_executable = ctx.actions.declare_file(ctx.label.name)
    output_dir = output_executable.dirname
    
    worker = scala_native_toolchain.linker_binary[DefaultInfo].files_to_run
    
    # Arguments
    args = ctx.actions.args()
    args.add("--main", main_class)
    args.add("--output", output_dir)
    args.add("--module_name", module_name)
    args.add("--workdir", output_dir + "/_native_work")
    args.add("--clang", clang_path)
    args.add("--clang++", clang_pp_path)
    args.add("--linking_option", "-fuse-ld=lld")
    # Flatten the classpath elements into a single string with the path separator
    # NativeLinkel expects path separator.
    args.add_joined("--cp", classpath, join_with=ctx.configuration.host_path_separator)

    ctx.actions.run(
        outputs = [output_executable],
        inputs = depset(transitive = [
            scala_native_toolchain.linker_binary[DefaultInfo].files,
            classpath,
            cc_toolchain.all_files,
        ]),
        executable = worker, 
        arguments = [args],
        mnemonic = "ScalaNativeLink",
        progress_message = "Linking %s" % module_name,
        toolchain = "//scala_native:toolchain_type",
    )
    
    return [
        DefaultInfo(
            executable = output_executable,
            files = depset([output_executable]),
        )
    ]

_scala_native_binary_attrs = {
    "main_class": attr.string(mandatory = True),
    "deps": attr.label_list(providers = [JavaInfo]),
    "_cc_toolchain": attr.label(
        default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
    ),
}

_scala_native_binary_attrs.update(toolchain_transition_attr)

scala_native_binary = rule(
    implementation = _scala_native_binary_impl,
    attrs = _scala_native_binary_attrs,
    executable = True,
    toolchains = [
        "//scala_native:toolchain_type", 
        "@bazel_tools//tools/cpp:toolchain_type"
    ],
    fragments = ["cpp"],
    cfg = scala_version_transition,
)
