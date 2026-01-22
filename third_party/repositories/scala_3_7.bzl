"""Maven artifact repository metadata.

Mostly generated and updated by scripts/create_repository.py.
"""

scala_version = "3.7.4"

artifacts = {
    "com_github_jnr_jffi_native": {
        "testonly": True,
        "artifact": "com.github.jnr:jffi:jar:native:1.2.17",
        "sha256": "4eb582bc99d96c8df92fc6f0f608fd123d278223982555ba16219bf8be9f75a9",
    },
    "com_google_android_annotations": {
        "artifact": "com.google.android:annotations:4.1.1.4",
        "sha256": "ba734e1e84c09d615af6a09d33034b4f0442f8772dec120efb376d86a565ae15",
    },
    "com_google_code_findbugs_jsr305": {
        "artifact": "com.google.code.findbugs:jsr305:3.0.2",
        "sha256": "766ad2a0783f2687962c8ad74ceecc38a28b9f72a2d085ee438b7813e928d0c7",
    },
    "com_google_code_gson_gson": {
        "artifact": "com.google.code.gson:gson:2.11.0",
        "sha256": "57928d6e5a6edeb2abd3770a8f95ba44dce45f3b23b7a9dc2b309c581552a78b",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
        ],
    },
    "com_google_errorprone_error_prone_annotations": {
        "artifact": "com.google.errorprone:error_prone_annotations:2.41.0",
        "sha256": "a56e782b5b50811ac204073a355a21d915a2107fce13ec711331ad036f660fcc",
    },
    "com_google_guava_guava_21_0": {
        "testonly": True,
        "artifact": "com.google.guava:guava:21.0",
        "sha256": "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
        "deps": [
            "@org_springframework_spring_core",
        ],
    },
    "com_google_guava_guava_21_0_with_file": {
        "testonly": True,
        "artifact": "com.google.guava:guava:21.0",
        "sha256": "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
    },
    "com_google_j2objc_j2objc_annotations": {
        "artifact": "com.google.j2objc:j2objc-annotations:3.1",
        "sha256": "84d3a150518485f8140ea99b8a985656749629f6433c92b80c75b36aba3b099b",
    },
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:4.33.4",
        "sha256": "3ca892fd6ea8b37d01bb6917dbc0bf2637548b756753f65a28d4f1d4d982347f",
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.13:0.5.1",
        "sha256": "e50796c69261fac857469122ab75f5aab4aeef855ca414f184cb132b318c2d9d",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.13:2.1.3",
        "sha256": "5064d3984aab8c48d2dbd6285787ac5c6d84a6bebfc02c6d431ce153cf91dec1",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_geny": {
        "artifact": "com.lihaoyi:geny_3:1.1.1",
        "sha256": "39658649f90b631a4fd63187724f16ba8a045e1b10a513528f34517fb2edf98b",
    },
    "com_lihaoyi_pprint": {
        "artifact": "com.lihaoyi:pprint_3:0.9.0",
        "sha256": "61afea0579ee81727b44cdd490d13bedeb57cb50ad437797fd9c8c9865d0b795",
        "deps": [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.13:0.4.4",
        "sha256": "bd4e99aef8267a410b6ed716c487cf5256f801425f158a8c9cbd056eb032d80d",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "com_twitter__scalding_date": {
        "testonly": True,
        "artifact": "com.twitter:scalding-date_2.13:0.17.0",
        "sha256": "973a7198121cc8dac9eeb3f325c93c497fe3b682f68ba56e34c1b210af7b15b4",
    },
    "com_typesafe_config": {
        "artifact": "com.typesafe:config:1.4.5",
        "sha256": "4a4b0affb22a9572409d3a6bde99ce3f2045c551cadc1ca7fe09690892c526c3",
    },
    "dev_dirs_directories": {
        "artifact": "dev.dirs:directories:26",
        "sha256": "6d18fe25aa30b7e08b908cd21151d8f96e22965c640acd7751add9bbfe6137d4",
    },
    "io_bazel_rules_scala_failureaccess": {
        "artifact": "com.google.guava:failureaccess:1.0.3",
        "sha256": "cbfc3906b19b8f55dd7cfd6dfe0aa4532e834250d7f080bd8d211a3e246b59cb",
    },
    "io_bazel_rules_scala_guava": {
        "artifact": "com.google.guava:guava:33.5.0-jre",
        "sha256": "1e301f0c52ac248b0b14fdc3d12283c77252d4d6f48521d572e7d8c4c2cc4ac7",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
            "@com_google_j2objc_j2objc_annotations",
            "@io_bazel_rules_scala_failureaccess",
            "@org_jspecify_jspecify",
        ],
    },
    "io_bazel_rules_scala_javax_annotation_api": {
        "artifact": "javax.annotation:javax.annotation-api:1.3.2",
        "sha256": "e04ba5195bcd555dc95650f7cc614d151e4bcd52d29a10b8aa2197f3ab89ab9b",
    },
    "io_bazel_rules_scala_junit_junit": {
        "artifact": "junit:junit:4.12",
        "sha256": "59721f0805e223d84b90677887d9ff567dc534d7c502ca903c0c2b17f05c116a",
    },
    "io_bazel_rules_scala_mustache": {
        "artifact": "com.github.spullara.mustache.java:compiler:0.8.18",
        "sha256": "ddabc1ef897fd72319a761d29525fd61be57dc25d04d825f863f83cc89000e66",
    },
    "io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple": {
        "artifact": "net.sf.jopt-simple:jopt-simple:5.0.4",
        "sha256": "df26cc58f235f477db07f753ba5a3ab243ebe5789d9f89ecf68dd62ea9a66c28",
    },
    "io_bazel_rules_scala_org_apache_commons_commons_math3": {
        "artifact": "org.apache.commons:commons-math3:3.6.1",
        "sha256": "1e56d7b058d28b65abd256b8458e3885b674c1d588fa43cd7d1cbb9c7ef2b308",
    },
    "io_bazel_rules_scala_org_hamcrest_hamcrest_core": {
        "artifact": "org.hamcrest:hamcrest-core:1.3",
        "sha256": "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_core": {
        "artifact": "org.openjdk.jmh:jmh-core:1.36",
        "sha256": "f90974e37d0da8886b5c05e6e3e7e20556900d747c5a41c1023b47c3301ea73c",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm": {
        "artifact": "org.openjdk.jmh:jmh-generator-asm:1.36",
        "sha256": "7460b11b823dee74b3e19617d35d5911b01245303d6e31c30f83417cfc2f54b5",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection": {
        "artifact": "org.openjdk.jmh:jmh-generator-reflection:1.36",
        "sha256": "a9c72760e12c199e2a2c28f1a126ebf0cc5b51c0b58d46472596fc32f7f92534",
    },
    "io_bazel_rules_scala_org_ow2_asm_asm": {
        "artifact": "org.ow2.asm:asm:9.0",
        "sha256": "0df97574914aee92fd349d0cb4e00f3345d45b2c239e0bb50f0a90ead47888e0",
    },
    "io_bazel_rules_scala_org_specs2_specs2_common": {
        "artifact": "org.specs2:specs2-common_3:jar:5.0.0-RC-21",
        "sha256": "bfbc91a136493483ed5d2beba7f48520e72b66a9987ebec5b8f0ca38bda02801",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_core": {
        "artifact": "org.specs2:specs2-core_3:jar:5.0.0-RC-21",
        "sha256": "ad4197e181c5921e685ce30b38f8a536745c8f3728172df49f7be2256e675608",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_fp": {
        "artifact": "org.specs2:specs2-fp_3:jar:5.0.0-RC-21",
        "sha256": "60f26aa132decb52682bba7ce0355b0b749b1b5fe283ec8929b050bb794cc1b8",
    },
    "io_bazel_rules_scala_org_specs2_specs2_junit": {
        "artifact": "org.specs2:specs2-junit_3:jar:5.0.0-RC-21",
        "sha256": "7e8b2c8ab10e6ea1ee471fb0313ad4c81963f326aa66efc4a2f476815ac4f8d9",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_core",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_matcher": {
        "artifact": "org.specs2:specs2-matcher_3:jar:5.0.0-RC-21",
        "sha256": "e747c4f40f3a96bfec5ac4a4af7d6b8b8f6f74b2412513752730888f75050e0b",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
        ],
    },
    "io_bazel_rules_scala_scala_asm": {
        "artifact": "org.scala-lang.modules:scala-asm:9.8.0-scala-1",
        "sha256": "86af037580bdf9ce9c05f8b2afd734daf1a8564c38cd10ca5d08bf81508ad2e4",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala3-compiler_3:3.7.4",
        "sha256": "1a60682b898fb04753dec78f2904078d48670079b7ad5106d442a0f431d346e0",
        "deps": [
            "@io_bazel_rules_scala_scala_asm",
            "@io_bazel_rules_scala_scala_interfaces",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_tasty_core",
            "@org_jline_jline_reader",
            "@org_jline_jline_terminal",
            "@org_jline_jline_terminal_jni",
            "@org_scala_sbt_compiler_interface",
        ],
    },
    "io_bazel_rules_scala_scala_compiler_2": {
        "artifact": "org.scala-lang:scala-compiler:2.13.17",
        "sha256": "073ab364dc902519719bd6b9463562128abc5881d2a2e4b7a5e2d04cdd7bc025",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
            "@io_github_java_diff_utils_java_diff_utils",
            "@org_jline_jline",
        ],
    },
    "io_bazel_rules_scala_scala_interfaces": {
        "artifact": "org.scala-lang:scala3-interfaces:3.7.4",
        "sha256": "c19ba8ea1a13c7fcdef675353c8ddd671156cf220879dcb28b27e986aae31ea9",
    },
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala3-library_3:3.7.4",
        "sha256": "73089d33f763b94758170e0a66be978f9397c14b7795e343898aa89b3d7b6639",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "io_bazel_rules_scala_scala_library_2": {
        "artifact": "org.scala-lang:scala-library:2.13.18",
        "sha256": "4e85d96ff7bc7dc627985523c3541b9917aaa08e956391380c42db21a2c4e5a0",
    },
    "io_bazel_rules_scala_scala_parallel_collections": {
        "artifact": "org.scala-lang.modules:scala-parallel-collections_2.13:1.2.0",
        "sha256": "4eae6e68cf44e9f709970355590ae981883edf6484608d747376a56cbb285432",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.13:2.4.0",
        "sha256": "e36dccdc21fd4bc770907a9e126d7e3901e71a191eb9ea8e93a0227774e0945d",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "io_bazel_rules_scala_scala_reflect_2": {
        "artifact": "org.scala-lang:scala-reflect:2.13.18",
        "sha256": "6935ff1982b2ac93d695f15aa66921be2f602921277afe002f018fd8c7d6e29b",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "io_bazel_rules_scala_scala_tasty_core": {
        "artifact": "org.scala-lang:tasty-core_3:3.7.4",
        "sha256": "24dfe7089232a42d28d5bee1209f462e4b4ca90622e0b13752399c12585e3069",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_3:2.1.0",
        "sha256": "48f22343575f4b1d6550eecc42d4b7f0a0d30223c72f015d8d893feab4cbeecd",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_3:3.2.19",
        "sha256": "26ef71a6d0993301d28d9693bada18ff81b373336b70368fcff01ed4eb4b958e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_3:3.2.19",
        "sha256": "cd886ba42615fe0d730dd57197e6ee53eeb062cfd0b4d8c5d9757c977c0fdcf8",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
            "@io_bazel_rules_scala_scalatest_diagrams",
            "@io_bazel_rules_scala_scalatest_featurespec",
            "@io_bazel_rules_scala_scalatest_flatspec",
            "@io_bazel_rules_scala_scalatest_freespec",
            "@io_bazel_rules_scala_scalatest_funspec",
            "@io_bazel_rules_scala_scalatest_funsuite",
            "@io_bazel_rules_scala_scalatest_matchers_core",
            "@io_bazel_rules_scala_scalatest_mustmatchers",
            "@io_bazel_rules_scala_scalatest_propspec",
            "@io_bazel_rules_scala_scalatest_refspec",
            "@io_bazel_rules_scala_scalatest_shouldmatchers",
            "@io_bazel_rules_scala_scalatest_wordspec",
        ],
    },
    "io_bazel_rules_scala_scalatest_compatible": {
        "artifact": "org.scalatest:scalatest-compatible:3.2.19",
        "sha256": "5dc6b8fa5396fe9e1a7c2b72df174a8eb3e92770cdc3e70636d3eba673cd0da3",
    },
    "io_bazel_rules_scala_scalatest_core": {
        "artifact": "org.scalatest:scalatest-core_3:3.2.19",
        "sha256": "f6e3d38c2034a9cab7313f644d8a933bf1b5241ff35002cc76916a427a826223",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_xml",
            "@io_bazel_rules_scala_scalactic",
            "@io_bazel_rules_scala_scalatest_compatible",
        ],
    },
    "io_bazel_rules_scala_scalatest_diagrams": {
        "artifact": "org.scalatest:scalatest-diagrams_3:3.2.19",
        "sha256": "835acf8ec2cb0d39beb1052ee2139029fdac28d172fc867db89ff49d640b255e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_3:3.2.19",
        "sha256": "3d49deeede2cd01578e037065862d7734afd3a6330c35dc3c4906f53f57302db",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_3:3.2.19",
        "sha256": "85a6fb2285f20445615c6780a498c3bca99e4c2aad32fab6f74202bdc61e56a9",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_3:3.2.19",
        "sha256": "ebc8573874766368316366495dcdfe0cca6d8082dc9cc08b5a2fd0834cdaecc0",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_3:3.2.19",
        "sha256": "872b6889fac777aa813d21fb5f1e89710407785a61eb18a570142b6be10389a7",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_3:3.2.19",
        "sha256": "42129cc156bd8978d9a438abd57001fc42ababf18f6178cbee91d0a9489334e0",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_3:3.2.19",
        "sha256": "723fecdf0ea4542947ef5174068c4e05cd2145a3dcb6ffc797079368c94a187e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_3:3.2.19",
        "sha256": "837f76b73ff299fb6748ba0aff4eb7c9d9c00252741ad2bc15af3998d2e0558c",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_propspec": {
        "artifact": "org.scalatest:scalatest-propspec_3:3.2.19",
        "sha256": "6b033e73f3a53717a32a0d4d35ae2021a0afe8a028c42da62fb937932934bce3",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_refspec": {
        "artifact": "org.scalatest:scalatest-refspec_3:3.2.19",
        "sha256": "827b78a65c25a1dc4af747a7711e24c785fae92c39600fd357a7d486fcce2e7a",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_3:3.2.19",
        "sha256": "76ddce37f710ea96bdb3eebcb4bb0a0125fc70fb2ebaa7cc74c9bd28284b6a23",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_wordspec": {
        "artifact": "org.scalatest:scalatest-wordspec_3:3.2.19",
        "sha256": "c6acce0958b086cb857c4da6107f903b6166a46dfa251f54d3a0869212e229c7",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scopt": {
        "artifact": "com.github.scopt:scopt_2.13:4.0.0-RC2",
        "sha256": "07c1937cba53f7509d2ac62a0fc375943a3e0fef346625414c15d41b5a6cfb34",
    },
    "io_bazel_rules_scala_scrooge_core": {
        "artifact": "com.twitter:scrooge-core_2.13:21.2.0",
        "sha256": "a93f179b96e13bd172e5164c587a3645122f45f6d6370304e06d52e2ab0e456f",
    },
    "io_bazel_rules_scala_scrooge_generator": {
        "artifact": "com.twitter:scrooge-generator_2.13:21.2.0",
        "sha256": "1293391da7df25497cad7c56cf8ecaeb672496a548d144d7a2a1cfcf748bed6c",
        "runtime_deps": [
            "@io_bazel_rules_scala_guava",
            "@io_bazel_rules_scala_mustache",
            "@io_bazel_rules_scala_scopt",
        ],
    },
    "io_bazel_rules_scala_util_core": {
        "artifact": "com.twitter:util-core_2.13:21.2.0",
        "sha256": "da8e149b8f0646316787b29f6e254250da10b4b31d9a96c32e42f613574678cd",
    },
    "io_bazel_rules_scala_util_logging": {
        "artifact": "com.twitter:util-logging_2.13:21.2.0",
        "sha256": "90bd8318329907dcf7e161287473e27272b38ee6857e9d56ee8a1958608cc49d",
    },
    "io_github_java_diff_utils_java_diff_utils": {
        "artifact": "io.github.java-diff-utils:java-diff-utils:4.16",
        "sha256": "620403030d676a4a27f780a3acec7438dee1b1651a1c804fa6bb11bb07399a6f",
    },
    "libthrift": {
        "artifact": "org.apache.thrift:libthrift:0.8.0",
        "sha256": "adea029247c3f16e55e29c1708b897812fd1fe335ac55fe3903e5d2f428ef4b3",
    },
    "net_java_dev_jna_jna": {
        "artifact": "net.java.dev.jna:jna:5.17.0",
        "sha256": "b3a9408e7c51e08ef0e3bfcc08f443f6ec0f6191ba8cd7c18d53d2b22e5bdbc0",
    },
    "org_apache_commons_commons_lang_3_5": {
        "testonly": True,
        "artifact": "org.apache.commons:commons-lang3:3.5",
        "sha256": "8ac96fc686512d777fca85e144f196cd7cfe0c0aec23127229497d1a38ff651c",
    },
    "org_checkerframework_checker_qual": {
        "artifact": "org.checkerframework:checker-qual:3.43.0",
        "sha256": "3fbc2e98f05854c3df16df9abaa955b91b15b3ecac33623208ed6424640ef0f6",
    },
    "org_codehaus_mojo_animal_sniffer_annotations": {
        "artifact": "org.codehaus.mojo:animal-sniffer-annotations:1.24",
        "sha256": "c720e6e5bcbe6b2f48ded75a47bccdb763eede79d14330102e0d352e3d89ed92",
    },
    "org_jline_jline": {
        "artifact": "org.jline:jline:jar:jdk8:3.30.6",
        "sha256": "beb0039b0ebd18b68240082715ba57cec1b85e43e667758df4a9c34e4f9dd0a3",
    },
    "org_jline_jline_native": {
        "artifact": "org.jline:jline-native:3.30.6",
        "sha256": "43c36f0934545a9549fb3c8ff3afa361c320efe1c94759ecd09b340648397c80",
    },
    "org_jline_jline_reader": {
        "artifact": "org.jline:jline-reader:3.30.6",
        "sha256": "065ca5599713a8bf80fb11b24401ebe5be92816cda0fa9b73450d767a86dd07f",
        "deps": [
            "@org_jline_jline_terminal",
        ],
    },
    "org_jline_jline_terminal": {
        "artifact": "org.jline:jline-terminal:3.30.6",
        "sha256": "9a8dfde8a25b0a9687cf11e0dd4a128665e831f14f9ced85ffc284d3adbad374",
        "deps": [
            "@org_jline_jline_native",
        ],
    },
    "org_jline_jline_terminal_jna": {
        "artifact": "org.jline:jline-terminal-jna:3.30.6",
        "sha256": "0104b9ae3fc3ac12b6810c31587a9c3c2a6a384cd42d4fcfed166e65c21f59f9",
        "deps": [
            "@net_java_dev_jna_jna",
            "@org_jline_jline_terminal",
        ],
    },
    "org_jline_jline_terminal_jni": {
        "artifact": "org.jline:jline-terminal-jni:3.30.6",
        "sha256": "f42a21ac1121e253673a377aafec24330d8b646d831e1e02ac856c16a92de95e",
        "deps": [
            "@org_jline_jline_native",
            "@org_jline_jline_terminal",
        ],
    },
    "org_jspecify_jspecify": {
        "artifact": "org.jspecify:jspecify:1.0.0",
        "sha256": "1fad6e6be7557781e4d33729d49ae1cdc8fdda6fe477bb0cc68ce351eafdfbab",
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.13:2.14.0",
        "sha256": "95986ac32df70c9ebdd96edfb276cdc038deedbe600177a45f6584022f34a13f",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.13.17",
        "sha256": "ff41633c298d3c1c35f1e31ca5284e25115a094ed9682cdd71ced6a5d04a5165",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler_2",
        ],
    },
    "org_scala_sbt_compiler_interface": {
        "artifact": "org.scala-sbt:compiler-interface:1.11.0",
        "sha256": "3025d1075a041054e64e53b68000bc9d7f280c6100ecf3840eefaeb44af8cac9",
        "deps": [
            "@org_scala_sbt_util_interface",
        ],
    },
    "org_scala_sbt_util_interface": {
        "artifact": "org.scala-sbt:util-interface:1.11.7",
        "sha256": "2f0c310d64997064733d2185458bd236ed4c6af7d006469e92101c0c4d52e147",
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.13:4.14.2",
        "sha256": "65ae0a0d19a8a7a42d223d1783ab25551d9a4dd1dde3eccbdae9f61475b9349f",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scalameta_fastparse": {
        "artifact": "org.scalameta:fastparse-v2_2.13:2.3.1",
        "sha256": "8fca8597ad6d7c13c48009ee13bbe80c176b08ab12e68af54a50f7f69d8447c5",
        "deps": [
            "@com_lihaoyi_geny",
            "@com_lihaoyi_sourcecode",
        ],
    },
    "org_scalameta_fastparse_utils": {
        "artifact": "org.scalameta:fastparse-utils_2.13:1.0.1",
        "sha256": "9d650543903836684a808bb4c5ff775a4cae4b38c3a47ce946b572237fde340f",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_io": {
        "artifact": "org.scalameta:io_2.13:4.14.2",
        "sha256": "5727df303a96acd8230f027ab735e01a6f500fc8a2f87ff4e0dbf02e90c651c6",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scalameta_mdoc_parser": {
        "artifact": "org.scalameta:mdoc-parser_2.13:2.8.0",
        "sha256": "e69201594c0a61c4ab593e1c5a17f69f012c2688327496b1578615352a5aed62",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scalameta_metaconfig_core": {
        "artifact": "org.scalameta:metaconfig-core_2.13:0.17.0",
        "sha256": "3ad7919a3b5d38dd2ae55cd965ea7af2f2ae4cba059a97fb60f2ce775af99f3f",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
            "@org_scala_lang_modules_scala_collection_compat",
            "@org_scalameta_metaconfig_pprint",
            "@org_typelevel_paiges_core",
        ],
    },
    "org_scalameta_metaconfig_pprint": {
        "artifact": "org.scalameta:metaconfig-pprint_2.13:0.17.0",
        "sha256": "9728204a7024db92f7b8fcd0e417dd627851c9cd1c929acf20520f6af64fd0bc",
        "deps": [
            "@com_lihaoyi_fansi",
            "@io_bazel_rules_scala_scala_compiler_2",
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
        ],
    },
    "org_scalameta_metaconfig_typesafe_config": {
        "artifact": "org.scalameta:metaconfig-typesafe-config_2.13:0.17.0",
        "sha256": "01f8023ddf6bbc50565c1d051b0b905e1a70c081fd0fcf45067d6d3e0d53de59",
        "deps": [
            "@com_typesafe_config",
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_metaconfig_core",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.13:4.14.2",
        "sha256": "a6218da688c27045d2d5094ffc64147d733205f947b314fc17609785a18bc423",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_config": {
        "artifact": "org.scalameta:scalafmt-config_2.13:3.10.2",
        "sha256": "77e6126965611073e4840b351db49a012a1c3710f8f430295e46c3a0481d7671",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_metaconfig_core",
            "@org_scalameta_metaconfig_typesafe_config",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.13:3.10.2",
        "sha256": "5eb876e7e3456bae15d4893ebf9d01dea5c066a8f8d8887c0a466d89a5bb7fe4",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_mdoc_parser",
            "@org_scalameta_scalafmt_config",
            "@org_scalameta_scalafmt_macros",
            "@org_scalameta_scalafmt_sysops",
        ],
    },
    "org_scalameta_scalafmt_macros": {
        "artifact": "org.scalameta:scalafmt-macros_2.13:3.10.2",
        "sha256": "7e9b06e221dbdad62c5e79857208dee4475acd0098f10010d483b0994ff79dc9",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
            "@org_scalameta_scalameta",
        ],
    },
    "org_scalameta_scalafmt_sysops": {
        "artifact": "org.scalameta:scalafmt-sysops_2.13:3.10.2",
        "sha256": "6d0a0d3473a0a741de01f0bb4bbb2afb825c58deb4914914c1f7d80dfa335631",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.13:4.14.2",
        "sha256": "b59a46e07948bbeb5e4fc3ad6d652ac23e0d213ed858858029d7ad263b5edf84",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.13:4.14.2",
        "sha256": "78ec41bfc8c16d2014fe9867be4707da70125032648f72406615d1b83251f8f4",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_common",
            "@org_scalameta_io",
        ],
    },
    "org_springframework_spring_core": {
        "testonly": True,
        "artifact": "org.springframework:spring-core:5.1.5.RELEASE",
        "sha256": "f771b605019eb9d2cf8f60c25c050233e39487ff54d74c93d687ea8de8b7285a",
    },
    "org_springframework_spring_tx": {
        "testonly": True,
        "artifact": "org.springframework:spring-tx:5.1.5.RELEASE",
        "sha256": "666f72b73c7e6b34e5bb92a0d77a14cdeef491c00fcb07a1e89eb62b08500135",
        "deps": [
            "@org_springframework_spring_core",
        ],
    },
    "org_typelevel__cats_core": {
        "testonly": True,
        "artifact": "org.typelevel:cats-core_3:jar:2.7.0",
        "sha256": "6f3e17cb666886b7f21998e981ebf45966fe951898f851437a518a93cab667bd",
    },
    "org_typelevel_kind_projector": {
        "artifact": "org.typelevel:kind-projector_2.13.16:0.13.4",
        "sha256": "e4bac237aae1a530cc5c7f0c98723a2f9e4890b8ef02a8d0aa2afa8c79dce6c0",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler_2",
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.13:0.4.4",
        "sha256": "ffbd59d3648e71c5b8f4474a54121fb3512707e7901245831669aa9e85f3bbf0",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "scala_proto_rules_disruptor": {
        "artifact": "com.lmax:disruptor:3.4.2",
        "sha256": "f412ecbb235c2460b45e63584109723dea8d94b819c78c9bfc38f50cba8546c0",
    },
    "scala_proto_rules_grpc_api": {
        "artifact": "io.grpc:grpc-api:1.77.0",
        "sha256": "f2de9b6e90484fb0fe3e19402611836465f6125c0384bc8d7ac3768f1bd5505f",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
        ],
    },
    "scala_proto_rules_grpc_context": {
        "artifact": "io.grpc:grpc-context:1.77.0",
        "sha256": "4801914d46b357653418521b47d277bf902df949b1da416f3469477a4575f1ee",
        "deps": [
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_core": {
        "artifact": "io.grpc:grpc-core:1.77.0",
        "sha256": "a19475cfefb3fafeb6ac742cf798ba5bda8c4c449c6609c73babe4285f38f4dc",
        "deps": [
            "@com_google_android_annotations",
            "@com_google_code_gson_gson",
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_context",
            "@scala_proto_rules_perfmark_api",
        ],
    },
    "scala_proto_rules_grpc_netty": {
        "artifact": "io.grpc:grpc-netty:1.77.0",
        "sha256": "f9ecc76f01da349f1b9ba4ae598caca16229ec575f0ecd3fcbf5a2480de2527e",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_core",
            "@scala_proto_rules_grpc_util",
            "@scala_proto_rules_netty_codec_http2",
            "@scala_proto_rules_netty_handler_proxy",
            "@scala_proto_rules_netty_transport_native_unix_common",
            "@scala_proto_rules_perfmark_api",
        ],
    },
    "scala_proto_rules_grpc_protobuf": {
        "artifact": "io.grpc:grpc-protobuf:1.77.0",
        "sha256": "4bd2904bc3cdcfd643672622086b432c38a91741f40219d5b72a2cef917fa093",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@com_google_protobuf_protobuf_java",
            "@io_bazel_rules_scala_guava",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_protobuf_lite",
            "@scala_proto_rules_proto_google_common_protos",
        ],
    },
    "scala_proto_rules_grpc_protobuf_lite": {
        "artifact": "io.grpc:grpc-protobuf-lite:1.77.0",
        "sha256": "dc6984ba0b2c4a6b7260f1a089be5a60678ff2f1ccb82b6749397e5ca26d8a79",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@io_bazel_rules_scala_guava",
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_stub": {
        "artifact": "io.grpc:grpc-stub:1.77.0",
        "sha256": "70bbc9baadb4aac26b721c1b9ed2a2cf77728162f9ac047a5652600f7c7e12de",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_util": {
        "artifact": "io.grpc:grpc-util:1.77.0",
        "sha256": "6bc46267324a5c48c5ea706dab8b7286d2c22ea920c3ec8583ee45dca4ff0dca",
        "deps": [
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_core",
        ],
    },
    "scala_proto_rules_instrumentation_api": {
        "artifact": "com.google.instrumentation:instrumentation-api:0.3.0",
        "sha256": "671f7147487877f606af2c7e39399c8d178c492982827305d3b1c7f5b04f1145",
    },
    "scala_proto_rules_netty_buffer": {
        "artifact": "io.netty:netty-buffer:4.1.127.Final",
        "sha256": "4a0a17dc5a58d910c56545be6912b9923cfe902522dc1df268e774bc22443eb6",
        "deps": [
            "@scala_proto_rules_netty_common",
        ],
    },
    "scala_proto_rules_netty_codec": {
        "artifact": "io.netty:netty-codec:4.1.127.Final",
        "sha256": "187d21cee1a114f43b87be235f66c83828bdd0a3e0c1cdfebedaa37748e6e470",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_http": {
        "artifact": "io.netty:netty-codec-http:4.1.127.Final",
        "sha256": "2408776c87c1808b5522298c25e8290427123763f4addfda02dff6a24a538f61",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_handler",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_http2": {
        "artifact": "io.netty:netty-codec-http2:4.1.127.Final",
        "sha256": "0eb1befa55f785b47729d58d4fce72abea73b7f48fc1c434d71953e6a558ffaa",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_codec_http",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_handler",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_socks": {
        "artifact": "io.netty:netty-codec-socks:4.1.127.Final",
        "sha256": "d3d251f9239951a845f22e39191f95471fb2eb7951b9878ea4555ccac99529fb",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_common": {
        "artifact": "io.netty:netty-common:4.1.127.Final",
        "sha256": "a6732bb70dc15ed96aa33ecca82c0d7b20f8ff41adf04f74f168f626adf359e8",
    },
    "scala_proto_rules_netty_handler": {
        "artifact": "io.netty:netty-handler:4.1.127.Final",
        "sha256": "88b6892bc1321d32409392e5b9f94e59d8e800678c029c71e7c0d76daf6050d0",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_resolver",
            "@scala_proto_rules_netty_transport",
            "@scala_proto_rules_netty_transport_native_unix_common",
        ],
    },
    "scala_proto_rules_netty_handler_proxy": {
        "artifact": "io.netty:netty-handler-proxy:4.1.127.Final",
        "sha256": "2c0c8046e5d737e08f40a7c2907526648860d0434e125bd51de3c2cf390453fb",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_codec_http",
            "@scala_proto_rules_netty_codec_socks",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_resolver": {
        "artifact": "io.netty:netty-resolver:4.1.127.Final",
        "sha256": "a57ee62deb54ed99690db2696039f0f768a65c974677946ed48b2a2d8510ded3",
        "deps": [
            "@scala_proto_rules_netty_common",
        ],
    },
    "scala_proto_rules_netty_transport": {
        "artifact": "io.netty:netty-transport:4.1.127.Final",
        "sha256": "0d1ad82bc658f9919ca750cebe2571d4b0ae4514ec781964091f405343760e92",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_resolver",
        ],
    },
    "scala_proto_rules_netty_transport_native_unix_common": {
        "artifact": "io.netty:netty-transport-native-unix-common:4.1.127.Final",
        "sha256": "0e3a45e3ce1fe034ca8b32c1579afa5f06729ca6427b7b0610528c4ef37c6e50",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_opencensus_api": {
        "artifact": "io.opencensus:opencensus-api:0.22.1",
        "sha256": "62a0503ee81856ba66e3cde65dee3132facb723a4fa5191609c84ce4cad36127",
    },
    "scala_proto_rules_opencensus_contrib_grpc_metrics": {
        "artifact": "io.opencensus:opencensus-contrib-grpc-metrics:0.22.1",
        "sha256": "3f6f4d5bd332c516282583a01a7c940702608a49ed6e62eb87ef3b1d320d144b",
    },
    "scala_proto_rules_opencensus_impl": {
        "artifact": "io.opencensus:opencensus-impl:0.22.1",
        "sha256": "9e8b209da08d1f5db2b355e781b9b969b2e0dab934cc806e33f1ab3baed4f25a",
    },
    "scala_proto_rules_opencensus_impl_core": {
        "artifact": "io.opencensus:opencensus-impl-core:0.22.1",
        "sha256": "04607d100e34bacdb38f93c571c5b7c642a1a6d873191e25d49899668514db68",
    },
    "scala_proto_rules_perfmark_api": {
        "artifact": "io.perfmark:perfmark-api:0.27.0",
        "sha256": "c7b478503ec524e55df19b424d46d27c8a68aeb801664fadd4f069b71f52d0f6",
    },
    "scala_proto_rules_proto_google_common_protos": {
        "artifact": "com.google.api.grpc:proto-google-common-protos:2.63.1",
        "sha256": "352ffc769f4d17e2d6227b6893ec368f4f07fbb069dd7aaa644b16949369f8b7",
        "deps": [
            "@com_google_protobuf_protobuf_java",
        ],
    },
    "scala_proto_rules_scalapb_compilerplugin": {
        "artifact": "com.thesamet.scalapb:compilerplugin_3:1.0.0-alpha.3",
        "sha256": "f61d76a09a6d8ccc25d0f98ab9f9172ad42659dd76a694c3b7294ba3e5a26a06",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
            "@scala_proto_rules_scalapb_protoc_gen",
        ],
    },
    "scala_proto_rules_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_3:1.0.0-alpha.3",
        "sha256": "ddf29b2aee3e88bd8f58948470965c296ef6e07f6e09f4e02ed7b19bafb78499",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "scala_proto_rules_scalapb_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.13:0.9.9",
        "sha256": "d3b70d7ef67e9186d25b10898b115d27bf2ccf53e9f3d136404420d2ec52ed66",
        "deps": [
            "@dev_dirs_directories",
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "scala_proto_rules_scalapb_protoc_gen": {
        "artifact": "com.thesamet.scalapb:protoc-gen_2.13:0.9.9",
        "sha256": "0adb3cedd175aa703d06aa58c914e3876a6e88613a63eb83d3e2a74592f1ba1b",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@scala_proto_rules_scalapb_protoc_bridge",
        ],
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_3:1.0.0-alpha.3",
        "sha256": "8b128634d64bf0a29c52001eabc12458e15c958843894a4020d181c7fc1d21fc",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
            "@scala_proto_rules_scalapb_lenses",
        ],
    },
    "scala_proto_rules_scalapb_runtime_grpc": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime-grpc_3:1.0.0-alpha.3",
        "sha256": "87400fb72734b26f058b35e6c13518f5e7a54d4dce3714452ce0df24cdb9d0c6",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
            "@scala_proto_rules_grpc_protobuf",
            "@scala_proto_rules_grpc_stub",
            "@scala_proto_rules_scalapb_runtime",
        ],
    },
}
