"""Maven artifact repository metadata.

Mostly generated and updated by scripts/create_repository.py.
"""

scala_version = "3.6.4"

artifacts = {
    "com_github_jnr_jffi_native": {
        "testonly": True,
        "artifact": "com.github.jnr:jffi:jar:native:1.2.17",
        "sha256": "4eb582bc99d96c8df92fc6f0f608fd123d278223982555ba16219bf8be9f75a9",
    },
    "com_google_android_annotations": {
        "artifact": "com.google.android:annotations:4.1.1.4",
        "sha256": "ba734e1e84c09d615af6a09d33034b4f0442f8772dec120efb376d86a565ae15",
        "srcjar_sha256": "e9b667aa958df78ea1ad115f7bbac18a5869c3128b1d5043feb360b0cfce9d40",
    },
    "com_google_code_findbugs_jsr305": {
        "artifact": "com.google.code.findbugs:jsr305:3.0.2",
        "sha256": "766ad2a0783f2687962c8ad74ceecc38a28b9f72a2d085ee438b7813e928d0c7",
        "srcjar_sha256": "1c9e85e272d0708c6a591dc74828c71603053b48cc75ae83cce56912a2aa063b",
    },
    "com_google_code_gson_gson": {
        "artifact": "com.google.code.gson:gson:2.12.1",
        "sha256": "ebee13d5fb7477cd7f1cc010e0c356df8ca80709715248da97f79e35ccb4fbec",
        "srcjar_sha256": "c5ab4ceb195f2a9278058d6a396c4872a1a07ed8b53fe80230dfd3f173d7cf56",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
        ],
    },
    "com_google_errorprone_error_prone_annotations": {
        "artifact": "com.google.errorprone:error_prone_annotations:2.45.0",
        "sha256": "6ba61510e22944e8aec3fe970972d088d8da132a24f2bc817a43c7b70665cc2b",
        "srcjar_sha256": "f8def362960be28236286f1c9ee9ba0112be25447c2a7c42efb13f8fc95a3016",
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
        "srcjar_sha256": "295938307f4016b3f128f7347101b236ada1394808104519c9e93cd61b64602b",
    },
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:4.33.5",
        "sha256": "cb9e00d6e3d4b1305f3fdc147490ce347bfe8c05dc821a433b23b2ff28749bb1",
        "srcjar_sha256": "efd3ceba03a47dbc38a8f95049d6885ad679d98514b0809ab4632884c4e97657",
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.13:0.5.1",
        "sha256": "e50796c69261fac857469122ab75f5aab4aeef855ca414f184cb132b318c2d9d",
        "srcjar_sha256": "b28dc640b3b412023f605d29320adc89f50b0511d7e1376f9bbf9b1032a1de5d",
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
        "srcjar_sha256": "854238ec90912d0621ec068cddd8854a81f67242785b5e6fbe42f87c255641e9",
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
        "srcjar_sha256": "4e17ad7d6a83922a9f1f7b65a33a2d33052a85314303d6f6e318ca3caf9c5d75",
    },
    "dev_dirs_directories": {
        "artifact": "dev.dirs:directories:26",
        "sha256": "6d18fe25aa30b7e08b908cd21151d8f96e22965c640acd7751add9bbfe6137d4",
        "srcjar_sha256": "192050e3a2a0eba7f22745765aaaf567ce6d515fe6a992688b4e262e9f14947b",
    },
    "io_bazel_rules_scala_failureaccess": {
        "artifact": "com.google.guava:failureaccess:1.0.3",
        "sha256": "cbfc3906b19b8f55dd7cfd6dfe0aa4532e834250d7f080bd8d211a3e246b59cb",
        "srcjar_sha256": "6fef4dfd2eb9f961655f2a3c4ea87c023618d9fcbfb6b104c17862e5afe66b97",
    },
    "io_bazel_rules_scala_guava": {
        "artifact": "com.google.guava:guava:33.5.0-jre",
        "sha256": "1e301f0c52ac248b0b14fdc3d12283c77252d4d6f48521d572e7d8c4c2cc4ac7",
        "srcjar_sha256": "79423ae87a2203950e0e3ce2a00682b3b8d8557e631bbf662dba5494fe3b55cb",
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
    "io_bazel_rules_scala_org_portable_scala_portable_scala_reflect_2_13": {
        "artifact": "org.portable-scala:portable-scala-reflect_2.13:1.1.1",
        "sha256": "11f2f59d0c228912811095025b36ce58a025a8397851d773295c8ad7862d8488",
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
        "deps": [
            "@io_bazel_rules_scala_org_portable_scala_portable_scala_reflect_2_13",
        ],
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
        "artifact": "org.scala-lang.modules:scala-asm:9.7.1-scala-1",
        "sha256": "3b764f500ee290ad44ff03db92c0de2b3ed920a1df531eab35a793f79b786379",
        "srcjar_sha256": "a1832f2d7b282d24fce82ca0b2d313d709ee74b82a1133dfa3e98d9b94e8705b",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala3-compiler_3:3.6.4",
        "sha256": "d0a38984801db97fd3d41c381a6807d6aabf517775de0d90e3bea0636e69ae2e",
        "srcjar_sha256": "6debf939ad54880010d7a742732041f5ee90d262eb45c9fb93e6f68b657ffe4e",
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
        "artifact": "org.scala-lang:scala-compiler:2.13.18",
        "sha256": "2f15891fcae7aad30a3892194fb2abb6224cf7ce5d2bd90fba7f1c48682fca21",
        "srcjar_sha256": "08d9984b0e8c553bdfd7b5fa6aa8c1d2f2f1cd6904399b9a0ab8eba345ded335",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
            "@io_github_java_diff_utils_java_diff_utils",
            "@org_jline_jline",
        ],
    },
    "io_bazel_rules_scala_scala_interfaces": {
        "artifact": "org.scala-lang:scala3-interfaces:3.6.4",
        "sha256": "d18678e1dbb080cf39666c629371a0d6df93177982d030607528a2d2da70e034",
        "srcjar_sha256": "6eb9c0871f5445548ad3389840f2dc8e48ed8af5203ae5839999ed18ea589a1c",
    },
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala3-library_3:3.6.4",
        "sha256": "a8c962526908331e077f70f391a7493e0cdbfd14edba8c1a780daee501ca06e6",
        "srcjar_sha256": "d355756b26c0085af072744ea8f659671077843c3c7b86ba2c486e093eb2390a",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "io_bazel_rules_scala_scala_library_2": {
        "artifact": "org.scala-lang:scala-library:2.13.18",
        "sha256": "4e85d96ff7bc7dc627985523c3541b9917aaa08e956391380c42db21a2c4e5a0",
        "srcjar_sha256": "bac5952705c53dce8a1a0ade4b6ca40900ac3421cd84dd6458ac683d768c3d18",
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
        "srcjar_sha256": "d400578b2eae8bcd251ff2fe3236fe7cf091cb38ec013982fc101ff102d6d8ee",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "io_bazel_rules_scala_scala_reflect_2": {
        "artifact": "org.scala-lang:scala-reflect:2.13.18",
        "sha256": "6935ff1982b2ac93d695f15aa66921be2f602921277afe002f018fd8c7d6e29b",
        "srcjar_sha256": "22c70ff11e4e38b9cc1bc3eb0131f3d4c3e46869f468c91829b97dc125d31fa1",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "io_bazel_rules_scala_scala_tasty_core": {
        "artifact": "org.scala-lang:tasty-core_3:3.6.4",
        "sha256": "6801af0a9dc297474e7b8ce81f2caa6b8b57a54e783d290a8728fa19d34f11da",
        "srcjar_sha256": "cc15418592a75ddd081e32a4c8c43027c678897027c4656283461e5c80f4e84b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_3:2.1.0",
        "sha256": "48f22343575f4b1d6550eecc42d4b7f0a0d30223c72f015d8d893feab4cbeecd",
        "srcjar_sha256": "b2f5f01c669f29dc03a8127f7a8ca2cdb40dff3e29ba416e3de4f6bef0480aca",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_3:3.2.19",
        "sha256": "26ef71a6d0993301d28d9693bada18ff81b373336b70368fcff01ed4eb4b958e",
        "srcjar_sha256": "bbfa9bf00870adf3587cc98dd374a32394e817c0a22a0285deed3fa20ef3e82c",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_3:3.2.19",
        "sha256": "cd886ba42615fe0d730dd57197e6ee53eeb062cfd0b4d8c5d9757c977c0fdcf8",
        "srcjar_sha256": "abbe71617ec5902d762fde00a9525262e5b3d9c1ed19dc2d58765eeb64eee373",
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
        "srcjar_sha256": "3e4471354f33698d9eeef51813f45747a9657ccc0dc615e284890936366f70a7",
    },
    "io_bazel_rules_scala_scalatest_core": {
        "artifact": "org.scalatest:scalatest-core_3:3.2.19",
        "sha256": "f6e3d38c2034a9cab7313f644d8a933bf1b5241ff35002cc76916a427a826223",
        "srcjar_sha256": "35d5214b0a97b1ca60d45244abd2c7d7b812edef856d8dbe1395fb10d14d2a8a",
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
        "srcjar_sha256": "c2d5f3735cc8d2f1b02e894378cb609c6104b106c6a64cd7cc3b67b4473d701e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_3:3.2.19",
        "sha256": "3d49deeede2cd01578e037065862d7734afd3a6330c35dc3c4906f53f57302db",
        "srcjar_sha256": "d195c96360999c4bf21de34157e5d5859d58072df671adb9abd78047d11056ab",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_3:3.2.19",
        "sha256": "85a6fb2285f20445615c6780a498c3bca99e4c2aad32fab6f74202bdc61e56a9",
        "srcjar_sha256": "3ce482355e5041f7011416b7f3263df41a366dc5de532f76d22519aec37694a5",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_3:3.2.19",
        "sha256": "ebc8573874766368316366495dcdfe0cca6d8082dc9cc08b5a2fd0834cdaecc0",
        "srcjar_sha256": "0e502172cf787b3d7f589bfdd73c51f5aa9196e3ab31b245f7f490a957c30db3",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_3:3.2.19",
        "sha256": "872b6889fac777aa813d21fb5f1e89710407785a61eb18a570142b6be10389a7",
        "srcjar_sha256": "50f3212eb85e590e15a425e9bb59031e84d034d91d339672b7c2b38b3f464a4e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_3:3.2.19",
        "sha256": "42129cc156bd8978d9a438abd57001fc42ababf18f6178cbee91d0a9489334e0",
        "srcjar_sha256": "4c7491e0ec87e5cef5952986294caa04bd261d823d31390abbed42baa3fe461e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_3:3.2.19",
        "sha256": "723fecdf0ea4542947ef5174068c4e05cd2145a3dcb6ffc797079368c94a187e",
        "srcjar_sha256": "58dedc4aa2fc18c024245f0f780a5cd6f20769c63a2c15ccf8a93917a7fe1fd2",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_3:3.2.19",
        "sha256": "837f76b73ff299fb6748ba0aff4eb7c9d9c00252741ad2bc15af3998d2e0558c",
        "srcjar_sha256": "699bbffcafb430285f72aec43d700b92a076ea6a322cf59d12d132381dcdbf6e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_propspec": {
        "artifact": "org.scalatest:scalatest-propspec_3:3.2.19",
        "sha256": "6b033e73f3a53717a32a0d4d35ae2021a0afe8a028c42da62fb937932934bce3",
        "srcjar_sha256": "304fb62b45deb001c8bfd8cf26603fb7362e585980bc2b806219674bce97ecd5",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_refspec": {
        "artifact": "org.scalatest:scalatest-refspec_3:3.2.19",
        "sha256": "827b78a65c25a1dc4af747a7711e24c785fae92c39600fd357a7d486fcce2e7a",
        "srcjar_sha256": "c1886564cfd390cadf8b0dff85bef4c14a71c54a77fde660cebfa5c36fcbd80c",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_3:3.2.19",
        "sha256": "76ddce37f710ea96bdb3eebcb4bb0a0125fc70fb2ebaa7cc74c9bd28284b6a23",
        "srcjar_sha256": "04e7e9601964516aa2d896574dac12b55fe96385e38f6fe80cb3514fcd9c82ba",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_wordspec": {
        "artifact": "org.scalatest:scalatest-wordspec_3:3.2.19",
        "sha256": "c6acce0958b086cb857c4da6107f903b6166a46dfa251f54d3a0869212e229c7",
        "srcjar_sha256": "7276bb382a85b38d8870da1dad80a98384c7da2a5ecc149d21101151e2e5ed2c",
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
        "srcjar_sha256": "1307a36819f8dac34187402947e2a9e850b9e7ce95dd5044524e4860c3378ab0",
    },
    "libthrift": {
        "artifact": "org.apache.thrift:libthrift:0.8.0",
        "sha256": "adea029247c3f16e55e29c1708b897812fd1fe335ac55fe3903e5d2f428ef4b3",
    },
    "net_java_dev_jna_jna": {
        "artifact": "net.java.dev.jna:jna:5.17.0",
        "sha256": "b3a9408e7c51e08ef0e3bfcc08f443f6ec0f6191ba8cd7c18d53d2b22e5bdbc0",
        "srcjar_sha256": "1e8dd4205deab6eb9d6045ad9e69a8754fc21029d56ede1dcd9f22a5e06571a7",
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
        "artifact": "org.codehaus.mojo:animal-sniffer-annotations:1.26",
        "sha256": "342f4d815eae69bb980620d0a622862709be37d38f47577675b42c739a962da9",
        "srcjar_sha256": "56d2844b620f4742f4b1c47d83357745b39cb26c45423d1249066c15eca31a86",
    },
    "org_jline_jline": {
        "artifact": "org.jline:jline:jar:jdk8:3.30.6",
        "sha256": "beb0039b0ebd18b68240082715ba57cec1b85e43e667758df4a9c34e4f9dd0a3",
    },
    "org_jline_jline_native": {
        "artifact": "org.jline:jline-native:3.30.6",
        "sha256": "43c36f0934545a9549fb3c8ff3afa361c320efe1c94759ecd09b340648397c80",
        "srcjar_sha256": "a0bcb1cc9bb3a9902ee4a6b1f7a16cac06734e7b44b6d7b85ba6b92693b67008",
    },
    "org_jline_jline_reader": {
        "artifact": "org.jline:jline-reader:3.30.6",
        "sha256": "065ca5599713a8bf80fb11b24401ebe5be92816cda0fa9b73450d767a86dd07f",
        "srcjar_sha256": "8c923f814f3fdffd432d42c4e2aa320c353d5fdfc39e0b0dd4754587e592fad2",
        "deps": [
            "@org_jline_jline_terminal",
        ],
    },
    "org_jline_jline_terminal": {
        "artifact": "org.jline:jline-terminal:3.30.6",
        "sha256": "9a8dfde8a25b0a9687cf11e0dd4a128665e831f14f9ced85ffc284d3adbad374",
        "srcjar_sha256": "5d52ad88f8b83c7e82f72c6d66795cbd9f605aa48b40c2d475e597af2c5d73ef",
        "deps": [
            "@org_jline_jline_native",
        ],
    },
    "org_jline_jline_terminal_jna": {
        "artifact": "org.jline:jline-terminal-jna:3.30.6",
        "sha256": "0104b9ae3fc3ac12b6810c31587a9c3c2a6a384cd42d4fcfed166e65c21f59f9",
        "srcjar_sha256": "e179977744b8b84c9d5812bbdbc40e1f27fd781171c7b6d6e7fadc0c3f356904",
        "deps": [
            "@net_java_dev_jna_jna",
            "@org_jline_jline_terminal",
        ],
    },
    "org_jline_jline_terminal_jni": {
        "artifact": "org.jline:jline-terminal-jni:3.30.6",
        "sha256": "f42a21ac1121e253673a377aafec24330d8b646d831e1e02ac856c16a92de95e",
        "srcjar_sha256": "c778016c9fb60e726eb50c28530195db222f25983c4c369d7de15eaa0a704e73",
        "deps": [
            "@org_jline_jline_native",
            "@org_jline_jline_terminal",
        ],
    },
    "org_jspecify_jspecify": {
        "artifact": "org.jspecify:jspecify:1.0.0",
        "sha256": "1fad6e6be7557781e4d33729d49ae1cdc8fdda6fe477bb0cc68ce351eafdfbab",
        "srcjar_sha256": "adf0898191d55937fb3192ba971826f4f294292c4a960740f3c27310e7b70296",
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.13:2.14.0",
        "sha256": "95986ac32df70c9ebdd96edfb276cdc038deedbe600177a45f6584022f34a13f",
        "srcjar_sha256": "56672b16b5573d4c91e66ae6682ab3ef6d0ff4335ebffc4fdfe408bb4117b409",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.13.18",
        "sha256": "278216a595f34d0cfb78ae710cb487f31d468fa5e883ffae8af0947b6f67c517",
        "srcjar_sha256": "c166028ba4a31b8ca9423389e1c5b2ca7d870695e217e7f1299507e3a4bb02c9",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler_2",
        ],
    },
    "org_scala_sbt_compiler_interface": {
        "artifact": "org.scala-sbt:compiler-interface:1.12.0",
        "sha256": "92f487a505eafdd0a033e4ff4f38a81509a655c76257c64e6808dd873cc145c3",
        "srcjar_sha256": "6e59d8fd35f900e2f96c2e3defe0c55c0a3577dde712a0912ffd1e7eae2fbaf0",
        "deps": [
            "@org_scala_sbt_util_interface",
        ],
    },
    "org_scala_sbt_util_interface": {
        "artifact": "org.scala-sbt:util-interface:1.12.4",
        "sha256": "cd6916d1e622c3e662bf58d739babae022a582ec48107f5fb84b25cc56b0c3dc",
        "srcjar_sha256": "293a0e9dd418801e9dfa90d1f65d88fe0063fa2d8dc477b50aa9e5b3b68a70f4",
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.13:4.15.0",
        "sha256": "530eaeeeebf8caf0183526fac90ca6691384840c02b390c373f685c9cf6a3a1c",
        "srcjar_sha256": "7fb15ab14147774bad75f8e044ff757655737e32e76f16658fa4b9b32ab65418",
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
        "artifact": "org.scalameta:io_2.13:4.15.0",
        "sha256": "b218f83d291d7860789dbc19998a70ff51ab8519d077c7dea66a3bb369cde8f3",
        "srcjar_sha256": "9078cf60f01f8f226d6f098f59354f7e118e4aba15e78e7f45a4fa90177bc468",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scalameta_mdoc_parser": {
        "artifact": "org.scalameta:mdoc-parser_2.13:2.8.2",
        "sha256": "d4123f01f875810f43379819527d1dc310a33b91fdcb48a423a760f21cd8aa05",
        "srcjar_sha256": "62bcd8509f7e0fc9e148c7668f86765c02e27c87acedf077306e1ff86789c32b",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scalameta_metaconfig_core": {
        "artifact": "org.scalameta:metaconfig-core_2.13:0.18.2",
        "sha256": "a7c38a68fb2d215e68842828255359b4ab36ca3a9c4b0652a736cee094ee500d",
        "srcjar_sha256": "b968cd04a80098a6e308e522733b984e7529c0b5d107a89e9641236f469a5630",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
            "@org_scala_lang_modules_scala_collection_compat",
            "@org_scalameta_metaconfig_pprint",
            "@org_typelevel_paiges_core",
        ],
    },
    "org_scalameta_metaconfig_pprint": {
        "artifact": "org.scalameta:metaconfig-pprint_2.13:0.18.2",
        "sha256": "2d8b1615d92684e5bb8b3bece69dfe6ed81508403b025ee8bcb43b856ad83674",
        "srcjar_sha256": "498254a90b97ff04a4d23a17486194ab3d49fb378ecb3d2eefa9a7691951035f",
        "deps": [
            "@com_lihaoyi_fansi",
            "@io_bazel_rules_scala_scala_compiler_2",
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
        ],
    },
    "org_scalameta_metaconfig_typesafe_config": {
        "artifact": "org.scalameta:metaconfig-typesafe-config_2.13:0.18.2",
        "sha256": "66279b219190fbe52899c120c231a63a562e2ca7b67e69cc78a79ce58da57cd0",
        "srcjar_sha256": "f769fafc6a7158a2dda3d3c69742f4a0b209affc278c011872a95230295ee485",
        "deps": [
            "@com_typesafe_config",
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_metaconfig_core",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.13:4.15.0",
        "sha256": "f6a295241a5aea7412f41d8fb4f28e40d88b7748bcf91684ec36827c0ccce84e",
        "srcjar_sha256": "b2053e1f57aced06d167be5e2de71695c2bd9c2b0337293b7aa27731f3d829e3",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_config": {
        "artifact": "org.scalameta:scalafmt-config_2.13:3.10.7",
        "sha256": "77ffba85d2a674bb1cd8574a6433407aa63ba045ef5c3b07904f110d3e269a2c",
        "srcjar_sha256": "78e1cc11f7d9557d526151219f33c3f7042f207ce30bd4bf8122cbe574663dc4",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_metaconfig_core",
            "@org_scalameta_metaconfig_typesafe_config",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.13:3.10.7",
        "sha256": "0be2991c2e0cbb454404eee062fa32c356b48361b0541b2cd3e5fbeed57a9d8f",
        "srcjar_sha256": "ca79bccf0b22578b0790d23de49c9e5ea242a386cc93e33509b2abf29d2767b4",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_mdoc_parser",
            "@org_scalameta_scalafmt_config",
            "@org_scalameta_scalafmt_macros",
            "@org_scalameta_scalafmt_sysops",
        ],
    },
    "org_scalameta_scalafmt_macros": {
        "artifact": "org.scalameta:scalafmt-macros_2.13:3.10.7",
        "sha256": "54cee00115b7d9e17706f839a68e3cc3530a31326bb189e82f17e62fa964d862",
        "srcjar_sha256": "e27cbf49845418c9f4d1dd94902ab23b6d58dbe9955ec6c3865b8bb631bf5f81",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@io_bazel_rules_scala_scala_reflect_2",
            "@org_scalameta_scalameta",
        ],
    },
    "org_scalameta_scalafmt_sysops": {
        "artifact": "org.scalameta:scalafmt-sysops_2.13:3.10.7",
        "sha256": "eb82049ecf849da04e7296669b4a8c2cdde82288b2e16b3973be5a346015264a",
        "srcjar_sha256": "b26086902e63fb49e89fedd38c15605bbe75ac60f0d26541b7719563bc35c80e",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.13:4.15.0",
        "sha256": "b3e3d85d87a3ccae0136ce056c9f3ab3bab35c350f70a4227c8f382df5cb5957",
        "srcjar_sha256": "6fc8c041be1923dc147d103d32b627d5e02dbc89580447c0c129912406b8855d",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.13:4.15.0",
        "sha256": "a5374fc65313e5e6bf3abef2d6ed7365ef205e088ac52fd3a02451a030e3719d",
        "srcjar_sha256": "0516430e32571fc374818ec005e0c4f40dae46ed41e54b95345c636ae7f5a8cd",
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
        "srcjar_sha256": "6eb5088d030c407040531668fe32ff87d0ec3313751228fdb261da8554c12784",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "scala_proto_rules_disruptor": {
        "artifact": "com.lmax:disruptor:3.4.2",
        "sha256": "f412ecbb235c2460b45e63584109723dea8d94b819c78c9bfc38f50cba8546c0",
    },
    "scala_proto_rules_grpc_api": {
        "artifact": "io.grpc:grpc-api:1.79.0",
        "sha256": "f09410380ddb66cfe52a5c865624be8af750433f0b550efdfab3dff9df2b97ac",
        "srcjar_sha256": "da30eec62596e05390e4ea28fa34d110e5d3e2596c8cecdedf98537f8054165d",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
        ],
    },
    "scala_proto_rules_grpc_context": {
        "artifact": "io.grpc:grpc-context:1.79.0",
        "sha256": "d911eb41290d3d6dd7ff521b77e80b455d58459e939fe8dbf21c4795d951655c",
        "srcjar_sha256": "65a958201c9c9a34c4ecfc98d3ac33a498e52940ed43bfb1eeee9f551f41a288",
        "deps": [
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_core": {
        "artifact": "io.grpc:grpc-core:1.79.0",
        "sha256": "3905dcc7d56288fa4b102f0af94f941c393167ec5fce1fc2a9662f2a9c53821b",
        "srcjar_sha256": "482ec98d4412d906cbba4b4bc3c51e61e41f94bcd153227b527c4221b6962627",
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
        "artifact": "io.grpc:grpc-netty:1.79.0",
        "sha256": "7cb02da891d6409459bb602be68e63be2419af12e96c97ff64ef758f6a150acd",
        "srcjar_sha256": "118af93f35064a48b86bdbc8480314265632141569299024bf748305140b6710",
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
        "artifact": "io.grpc:grpc-protobuf:1.79.0",
        "sha256": "3985a84170198c1a50d36011285ed43d78477c8e9a4b5e4a8ae038a03a8b8241",
        "srcjar_sha256": "4d919d895039f603bbbaa501bf0ee01de2adc5b43b36b2b2ed7cf0ab3fdde46a",
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
        "artifact": "io.grpc:grpc-protobuf-lite:1.79.0",
        "sha256": "27a1bc17bdd0a9f1432bd299d51773f5cf1f20e14a6fc943754a34be4029a596",
        "srcjar_sha256": "ffe979c8f74cb8f6b92b3566922b1d3893112321b564b57189cefc9e603efd34",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@io_bazel_rules_scala_guava",
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_stub": {
        "artifact": "io.grpc:grpc-stub:1.79.0",
        "sha256": "6ac28427db750e24dc89421230e63927fb49e9ec0bee8cecb0634c90785c8ac3",
        "srcjar_sha256": "b3b85e6756c699ddb66a6a685924b757875c97d506982b211f2dc70518af049d",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_util": {
        "artifact": "io.grpc:grpc-util:1.79.0",
        "sha256": "3ed8871e5f740f4d3254b6fc0011612d7e8be97b684dce36a763a9c599a95329",
        "srcjar_sha256": "f391cce848ffd7383469b8c205233f2450c995cea5b5b440c9cf3e84f23d2395",
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
        "artifact": "io.netty:netty-buffer:4.1.130.Final",
        "sha256": "00a522b67ea35cb7b4dd9cf27f85c6c58f5e306785aa045302e5f6b2d4944a87",
        "srcjar_sha256": "c30cbe8f4c131d6a99ddb84557a7b781923a2d3d980e11c8a7ca2934a39b88d0",
        "deps": [
            "@scala_proto_rules_netty_common",
        ],
    },
    "scala_proto_rules_netty_codec": {
        "artifact": "io.netty:netty-codec:4.1.130.Final",
        "sha256": "52636bc29bd62120b97bbe5d1d21eab9b1cb2bef8efbb54d2221c5f3fa08d8cd",
        "srcjar_sha256": "7865db4844cc11bc0530bef0b26b232a9c4fed52e2c59a4f70f1eabd51fb667b",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_http": {
        "artifact": "io.netty:netty-codec-http:4.1.130.Final",
        "sha256": "5b6addc1df7b3397a193bd6544a8bfdb18ecac99fd13bee4ec75b1781a664e5e",
        "srcjar_sha256": "ae30ea9700c45d53227a9dfcc3f229ea48c9f2066062183aacaf9ca675a99c95",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_handler",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_http2": {
        "artifact": "io.netty:netty-codec-http2:4.1.130.Final",
        "sha256": "f8ffdb550368fd5dee7c7f1393fa49552522f280ed8de96aebf4269cab0dc8f3",
        "srcjar_sha256": "882b21352c8301655d4df8b45c9975fc5519f76260f7ce3d5e37aeb76bdea049",
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
        "artifact": "io.netty:netty-codec-socks:4.1.130.Final",
        "sha256": "9b8f8b2fab256411936ddf5358c3eb6b184c49ea7b8b01f40d473fa94ed7b92c",
        "srcjar_sha256": "7657bd88e4d65c85d255047c2d5a942210f66f9a85cd6acbb4fdd2ff0a1f4aa0",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_common": {
        "artifact": "io.netty:netty-common:4.1.130.Final",
        "sha256": "53921f28dd5a352b1bed0e1cbcc54d013dc60ffebeae9b2b1e53eabef317e581",
        "srcjar_sha256": "9c986998ea0ed5416f15f93fa097d39c83e84ee7d64c954fae332b407a04f4ce",
    },
    "scala_proto_rules_netty_handler": {
        "artifact": "io.netty:netty-handler:4.1.130.Final",
        "sha256": "98c78ec187ca30a4b9775bf6f632f5c9929db6bf06a60e6971f945813880ca0f",
        "srcjar_sha256": "4fd9ed997c051fdf45f9a9283a0c461b09a5d5001b80f495508871ff048a7b4a",
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
        "artifact": "io.netty:netty-handler-proxy:4.1.130.Final",
        "sha256": "33656875d0001587eea4a9778cf2242b418bc887ed03b2d37ef3969e0b7d3b5e",
        "srcjar_sha256": "8f6b51692e0d2f8f228f8ff22eefa155a774194972bd814cbe34fbd052da7e21",
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
        "artifact": "io.netty:netty-resolver:4.1.130.Final",
        "sha256": "48c5b218a89d184e1b601d46433957f515fcefdb4464182b1348bce4f5a18f35",
        "srcjar_sha256": "d74be8e1306c4e17b783622cda547c33031b7f1957c77f07d1a29575ddb746e3",
        "deps": [
            "@scala_proto_rules_netty_common",
        ],
    },
    "scala_proto_rules_netty_transport": {
        "artifact": "io.netty:netty-transport:4.1.130.Final",
        "sha256": "1bf573266d271f856705a9984d25449c56a1d73c02a16af12033ceccfe555dbb",
        "srcjar_sha256": "ab3776dda65078cb019a8c6c5c10dfb66c72115a13f2d3248b52c2fc7c6f7414",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_resolver",
        ],
    },
    "scala_proto_rules_netty_transport_native_unix_common": {
        "artifact": "io.netty:netty-transport-native-unix-common:4.1.130.Final",
        "sha256": "cf5efc4168597d7cd14695b469418cac2a1134533f9a0c82ef0538d796fd39e1",
        "srcjar_sha256": "12f5691191952f07da3715fcbb29bea851ce6514cd69f4d88796d8da12a09526",
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
        "srcjar_sha256": "311551ab29cf51e5a8abee6a019e88dee47d1ea71deb9fcd3649db9c51b237bc",
    },
    "scala_proto_rules_proto_google_common_protos": {
        "artifact": "com.google.api.grpc:proto-google-common-protos:2.66.0",
        "sha256": "e50c79240ba7391bf860fb2661fe6354d25a42cba69ca4a30bcf4e3117368588",
        "srcjar_sha256": "2a54e6a470bf07d66b0774fff57ac5c91f080c8e300eae78a8294b298bceb08f",
        "deps": [
            "@com_google_protobuf_protobuf_java",
        ],
    },
    "scala_proto_rules_scalapb_compilerplugin": {
        "artifact": "com.thesamet.scalapb:compilerplugin_3:1.0.0-alpha.3",
        "sha256": "f61d76a09a6d8ccc25d0f98ab9f9172ad42659dd76a694c3b7294ba3e5a26a06",
        "srcjar_sha256": "052b989fe8dc5d49a9df3f7aa813fe2e6e5f02ea3b5e629d4d478c11236cfc20",
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
        "srcjar_sha256": "6a349905cd24fdc22d7f30527e21b54679e58ea5cd5c4966f0b96f3bf111fa61",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "scala_proto_rules_scalapb_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.13:0.9.9",
        "sha256": "d3b70d7ef67e9186d25b10898b115d27bf2ccf53e9f3d136404420d2ec52ed66",
        "srcjar_sha256": "c24b3ec355846168fce61b2d1ce0d7cee49079d799a1411b1cdea0d364c6794c",
        "deps": [
            "@dev_dirs_directories",
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "scala_proto_rules_scalapb_protoc_gen": {
        "artifact": "com.thesamet.scalapb:protoc-gen_2.13:0.9.9",
        "sha256": "0adb3cedd175aa703d06aa58c914e3876a6e88613a63eb83d3e2a74592f1ba1b",
        "srcjar_sha256": "6c4d621291ee88946049fc730c4ee8910d9ef6d7a1545297a50e8879c08b47b6",
        "deps": [
            "@io_bazel_rules_scala_scala_library_2",
            "@scala_proto_rules_scalapb_protoc_bridge",
        ],
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_3:1.0.0-alpha.3",
        "sha256": "8b128634d64bf0a29c52001eabc12458e15c958843894a4020d181c7fc1d21fc",
        "srcjar_sha256": "dbddbe90f391ec7d950b644deeb32797e4835659cd1f90689c8b27ec98a39af8",
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
        "srcjar_sha256": "9d4cca2fb1a3a3e623dacb87d8687b79120284507391081b4e157b5f151ad684",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
            "@scala_proto_rules_grpc_protobuf",
            "@scala_proto_rules_grpc_stub",
            "@scala_proto_rules_scalapb_runtime",
        ],
    },
}
