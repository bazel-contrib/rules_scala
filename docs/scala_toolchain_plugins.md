# Global Compiler Plugins via Scala Toolchain

Starting with this version, rules_scala supports configuring compiler plugins globally at the toolchain level. This allows you to enable compiler plugins for all Scala targets in your workspace without having to specify them in every BUILD file.

## Motivation

Previously, compiler plugins had to be specified on each individual `scala_library`, `scala_binary`, or `scala_test` target:

```starlark
scala_library(
    name = "lib1",
    srcs = ["Lib1.scala"],
    plugins = ["@org_typelevel_kind_projector//jar"],  # Repetitive
)

scala_library(
    name = "lib2",
    srcs = ["Lib2.scala"],
    plugins = ["@org_typelevel_kind_projector//jar"],  # Repetitive
)
```

With global plugins via toolchain, you can configure plugins once and have them apply everywhere.

## Usage

### Step 1: Define a Scala Toolchain with Plugins

Create a custom Scala toolchain that includes the `plugins` attribute:

```starlark
load("@io_bazel_rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "my_scala_toolchain_impl",
    plugins = [
        "@org_typelevel_kind_projector//jar",
        "@com_olegpy_better_monadic_for//jar",
        # Add more plugins as needed
    ],
    # Other toolchain configuration...
    visibility = ["//visibility:public"],
)

toolchain(
    name = "my_scala_toolchain",
    toolchain = ":my_scala_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
)
```

### Step 2: Register the Toolchain

Register your custom toolchain in your `WORKSPACE` file:

```starlark
register_toolchains("//path/to:my_scala_toolchain")
```

Or use the `--extra_toolchains` flag:

```bash
bazel build //... --extra_toolchains=//path/to:my_scala_toolchain
```

### Step 3: Use in Your Targets

Now all your Scala targets automatically have access to the global plugins:

```starlark
scala_library(
    name = "my_lib",
    srcs = ["MyLib.scala"],
    # No plugins attribute needed - they come from the toolchain!
)
```

## Combining Global and Target-Specific Plugins

Targets can still specify additional plugins via the `plugins` attribute. These will be combined with the global plugins from the toolchain:

```starlark
scala_library(
    name = "special_lib",
    srcs = ["SpecialLib.scala"],
    plugins = ["//my:custom_plugin"],  # This is added to the global plugins
)
```

In this case, `special_lib` will have both the global plugins from the toolchain AND the custom plugin specified in the target.

## Example: Enabling Kind Projector Globally

Here's a complete example of enabling the Kind Projector compiler plugin globally for Scala 2.12:

**BUILD.bazel** (in your workspace root or a dedicated toolchain package):
```starlark
load("@io_bazel_rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "scala_2_12_with_kind_projector_impl",
    plugins = ["@org_typelevel_kind_projector//jar"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scala_2_12_with_kind_projector",
    toolchain = ":scala_2_12_with_kind_projector_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
)
```

**WORKSPACE**:
```starlark
register_toolchains("//:scala_2_12_with_kind_projector")
```

Now all Scala code in your workspace can use Kind Projector syntax:

```scala
// Any scala_library can now use this without declaring the plugin
type EitherStr[A] = Either[String, A]
type StringOr[T] = Either[String, T]
```

## Migration Guide

To migrate from per-target plugins to global plugins:

1. Identify plugins used across multiple targets
2. Add them to your toolchain's `plugins` attribute
3. Remove the `plugins` attribute from individual targets
4. Test your build to ensure everything still compiles

## Benefits

- **Consistency**: Ensure all Scala code uses the same compiler plugins
- **Maintainability**: Update plugins in one place
- **Cleaner BUILD files**: Less boilerplate in target definitions
- **Flexibility**: Can still add target-specific plugins when needed

## Limitations

- Global plugins apply to ALL Scala targets using the toolchain
- If a plugin causes issues with specific targets, you may need to create multiple toolchains
- Plugin order matters - global plugins are loaded before target-specific plugins