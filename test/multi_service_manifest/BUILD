load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

sh_test(
    name = "multi_service_manifest_test",
    srcs = ["multi_service_manifest_test.sh"],
    args = [
        "$(rootpath //test:ScalaBinary_with_service_manifest_srcs_deploy.jar)",
        "$(rootpath //test/example_jars:expected_service_manifest.txt)",
    ],
    data = [
        "//test:ScalaBinary_with_service_manifest_srcs_deploy.jar",
        "//test/example_jars:expected_service_manifest.txt",
    ],
)
