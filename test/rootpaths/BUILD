load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

# Generate a file containing the rootpaths of a Scala binary.
genrule(
    name = "rootpath-script",
    srcs = ["//test:ScalaBinary"],
    outs = ["rootpath-script.out"],
    cmd = """
       rootpaths=($(rootpaths {}))
       (IFS='\n'; echo "$${{rootpaths[*]}}") | sort > $@
   """.format("//test:ScalaBinary"),
)

# Validate that the rootpaths point to both the binary
# and the JAR.
sh_test(
    name = "ScalaBinaryRootpaths",
    srcs = ["rootpaths_binary.sh"],
    args = ["$(rootpath :rootpath-script.out)"],
    data = [":rootpath-script.out"],
)
