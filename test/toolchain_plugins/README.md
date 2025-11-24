# Global Compiler Plugins via Toolchain

This directory demonstrates how to configure global compiler plugins that apply to all Scala targets through the toolchain.

## How to Use Global Plugins

### 1. Define a toolchain with plugins

In your `BUILD.bazel` or `WORKSPACE` file, define a Scala toolchain with the `plugins` attribute:

```starlark
scala_toolchain(
    name = "my_global_plugins_toolchain_impl",
    plugins = [
        "@org_typelevel_kind_projector//jar",
        "//path/to/another:plugin",
    ],
    # Other toolchain attributes...
)

toolchain(
    name = "my_global_plugins_toolchain",
    toolchain = ":my_global_plugins_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
)
```

### 2. Register the toolchain

Register your custom toolchain in the WORKSPACE file or via Bazel's `--extra_toolchains` flag:

```starlark
register_toolchains("//path/to:my_global_plugins_toolchain")
```

### 3. Use in your Scala targets

All `scala_library`, `scala_binary`, and `scala_test` targets will automatically have access to the global plugins:

```starlark
scala_library(
    name = "my_lib",
    srcs = ["MyLib.scala"],
    # No need to specify plugins - they come from the toolchain
)
```

### 4. Adding target-specific plugins

Targets can still specify additional plugins via the `plugins` attribute. These will be combined with the global plugins:

```starlark
scala_library(
    name = "my_lib_with_extra_plugin",
    srcs = ["MyLib.scala"],
    plugins = ["//my:additional_plugin"],  # Combined with global plugins
)
```

## Benefits

1. **Consistency**: Ensure all Scala code in your repository uses the same set of compiler plugins
2. **Maintainability**: Update plugins in one place instead of every BUILD file
3. **Flexibility**: Individual targets can still add their own plugins when needed
4. **Migration**: Gradually migrate from per-target plugins to global plugins

## Example Use Cases

- **Kind Projector**: Enable type lambda syntax across the entire codebase
- **Better Monadic For**: Improve for-comprehension desugaring globally
- **Silencer**: Suppress specific compiler warnings project-wide
- **Scala.js plugins**: Enable Scala.js compilation features
- **Custom linting/validation plugins**: Enforce coding standards across all targets