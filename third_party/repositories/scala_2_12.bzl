"""Maven artifact repository metadata.

Mostly generated and updated by scripts/create_repository.py.
"""

scala_version = "2.12.20"

artifacts = {
    "com_github_bigwheel_util_backports": {
        "artifact": "com.github.bigwheel:util-backports_2.12:2.1",
        "sha256": "0d2ae5753bc8ff9f221a52ef39e771d285eccc52b88cdce622212569d3bd0e1b",
    },
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
        "artifact": "com.lihaoyi:fansi_2.12:0.5.1",
        "sha256": "57bd285ff4c4aa706fbe26e08e344881b0fc05a1a7ef8928385fab9b5208de81",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.12:2.1.3",
        "sha256": "e8b831a843c0eb5105d42e4b6febfc772b3aed3a853a899e6c8196e9ecc057df",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_geny": {
        "artifact": "com.lihaoyi:geny_2.12:0.6.5",
        "sha256": "9e81e90ab3e380192e04926d546418d825853de8efea12a7f94e0bd04c250419",
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.12:0.4.4",
        "sha256": "b3be5e4f73dca4dfc8d2036198d5792163927318831258bdfbe9a786994a2ad1",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_twitter__scalding_date": {
        "testonly": True,
        "artifact": "com.twitter:scalding-date_2.12:0.17.0",
        "sha256": "973a7198121cc8dac9eeb3f325c93c497fe3b682f68ba56e34c1b210af7b15b3",
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
        "artifact": "org.specs2:specs2-common_2.12:4.4.1",
        "sha256": "7b7d2497bfe10ad552f5ab3780537c7db9961d0ae841098d5ebd91c78d09438a",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_core": {
        "artifact": "org.specs2:specs2-core_2.12:4.4.1",
        "sha256": "f92c3c83844aac13250acec4eb247a2a26a2b3f04e79ef1bf42c56de4e0bb2e7",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_fp": {
        "artifact": "org.specs2:specs2-fp_2.12:4.4.1",
        "sha256": "834a145b28dbf57ba6d96f02a3862522e693b5aeec44d4cb2f305ef5617dc73f",
    },
    "io_bazel_rules_scala_org_specs2_specs2_junit": {
        "artifact": "org.specs2:specs2-junit_2.12:4.4.1",
        "sha256": "c867824801da5cccf75354da6d12d406009c435865ecd08a881b799790e9ffec",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_core",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_matcher": {
        "artifact": "org.specs2:specs2-matcher_2.12:4.4.1",
        "sha256": "78c699001c307dcc5dcbec8a80cd9f14e9bdaa047579c3d1010ee4bea66805fe",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
        ],
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:2.12.20",
        "sha256": "c88676d75c69721b717ea6c441ece04fff262abab9d210a2936abc2be3731fa2",
        "deps": [
            "@io_bazel_rules_scala_scala_xml",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:2.12.20",
        "sha256": "4d8a8f984cce31a329a24f10b0bf336f042cb62aeb435290a1b20243154cfccb",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.12:2.4.0",
        "sha256": "23a8d4ddbb7d116dc7a4c41a33f362e5f908cb6b57210c6ed38e61a6c8e383ea",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:2.12.20",
        "sha256": "5f1914cdc7a70580ea6038d929ebb25736ecf2234f677e2d47f8a4b2bc81e1fb",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.12:2.3.0",
        "sha256": "4932c56a2d5aae77ae8d7ac6bed1f21d48268fdbac8b4e5f3ca5196ad10fd93e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.12:3.2.19",
        "sha256": "a50a3248208b25e9797c447709fe4276026510beae01e82366f405a66d9a8d57",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.12:3.2.19",
        "sha256": "9f7dc750bbd6eeb52f0d8bc7c542ace46da9efdca0128a5a92769a448e065a62",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
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
        "artifact": "org.scalatest:scalatest-core_2.12:3.2.19",
        "sha256": "57b683ac16954fae147182bae9619a1d3070286bc2febc18c059600dd2885a99",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scala_xml",
            "@io_bazel_rules_scala_scalactic",
            "@io_bazel_rules_scala_scalatest_compatible",
        ],
    },
    "io_bazel_rules_scala_scalatest_diagrams": {
        "artifact": "org.scalatest:scalatest-diagrams_2.12:3.2.19",
        "sha256": "4644e596643982591ab335adfecd55cd3ca773a859cd9a163bb14fed032b0c9f",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_2.12:3.2.19",
        "sha256": "a7173e04338830b03cb366839bd03deb1765e06bacd3414c306548ba03280016",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_2.12:3.2.19",
        "sha256": "b3974fa6f1f4b97b583ac94911adbb5b78a48a5c06101860d015f0e9df0e0131",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_2.12:3.2.19",
        "sha256": "008cad5f68215028f3120ce24cd8f40ee435260d14455143884da8f66496c7b2",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_2.12:3.2.19",
        "sha256": "24646029011aa0528cbba3d14320167f16604225eb72eaf95521134ac82944e6",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_2.12:3.2.19",
        "sha256": "4ccea10ecf3f1ecfd16d7cab4da2dbec965da1cebc5e956aeddc814e27845ba8",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_2.12:3.2.19",
        "sha256": "1048196692ce8ad06fed0e6fb41ce87d6b205646be3c2a78d3654ce90a9d5bc5",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_2.12:3.2.19",
        "sha256": "e879ad96f7c5ab558994b34d9a96cf50dc6b32f7c34e7df0586d72ba6c3cbddc",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_propspec": {
        "artifact": "org.scalatest:scalatest-propspec_2.12:3.2.19",
        "sha256": "7482f4b139e870f14b8d32f4ad57a11846d7d5e7ea6448aebd34416bee7c2749",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_refspec": {
        "artifact": "org.scalatest:scalatest-refspec_2.12:3.2.19",
        "sha256": "3c0ae4964bd2f56fd71404480724bf2ee94d081187ddf2704b603f897f1faa16",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_2.12:3.2.19",
        "sha256": "36e8fa4935945c913c6989e98050355814c2f6ee96b0b350da3cc76e471eb14f",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_wordspec": {
        "artifact": "org.scalatest:scalatest-wordspec_2.12:3.2.19",
        "sha256": "ff5c1ebe03dbf728f6d2a698b8757d940cbeae0102b4ba3301c4ef7447033e18",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scopt": {
        "artifact": "com.github.scopt:scopt_2.12:4.0.0-RC2",
        "sha256": "d19a4e8b8c013a56e03bc57bdf87abe6297c974cf907585d00284eae61c6ac91",
    },
    "io_bazel_rules_scala_scrooge_core": {
        "artifact": "com.twitter:scrooge-core_2.12:21.2.0",
        "sha256": "1178f6cef63c9ad9e787ee7dbb26008d2a8cec9afee7629d0037c534d5b5d575",
    },
    "io_bazel_rules_scala_scrooge_generator": {
        "artifact": "com.twitter:scrooge-generator_2.12:21.2.0",
        "sha256": "ac5afecfd742ce07cf127b253df20ebf265d75d02d5f38bd8c683da194780862",
        "runtime_deps": [
            "@io_bazel_rules_scala_guava",
            "@io_bazel_rules_scala_mustache",
            "@io_bazel_rules_scala_scopt",
        ],
    },
    "io_bazel_rules_scala_util_core": {
        "artifact": "com.twitter:util-core_2.12:21.2.0",
        "sha256": "5d4ed75a26a3a2cc7fdc1dbeb29878a70024a8b7864287ed1e182dbca9c775a5",
    },
    "io_bazel_rules_scala_util_logging": {
        "artifact": "com.twitter:util-logging_2.12:21.2.0",
        "sha256": "6110ea70a1ea65c477cec72b7a2ce2ec92427e081ff9366272cb7c3bcadf69a9",
    },
    "libthrift": {
        "artifact": "org.apache.thrift:libthrift:0.10.0",
        "sha256": "8591718c1884ac8001b4c5ca80f349c0a6deec691de0af720c5e3bc3a581dada",
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
    "org_jspecify_jspecify": {
        "artifact": "org.jspecify:jspecify:1.0.0",
        "sha256": "1fad6e6be7557781e4d33729d49ae1cdc8fdda6fe477bb0cc68ce351eafdfbab",
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.12:2.14.0",
        "sha256": "40d7c1719db7940a7101509dff407f1ff67baf01abd1f40547b04077d94a92e5",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.12.20",
        "sha256": "0b1fa8a5f222fdcace7e12378241bfc3ceabfaebd000a31e865a1111428eb283",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
        ],
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.12:4.14.2",
        "sha256": "bbcd06dbabddb2a336bb3c92ce91d983642c6e296667704f81175212cb179aef",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_fastparse": {
        "artifact": "org.scalameta:fastparse-v2_2.12:2.3.1",
        "sha256": "c8ddc110da4b2e3d204e44b2629f4663edeb61094fa7ab4749f2f82b1b0cb026",
        "deps": [
            "@com_lihaoyi_geny",
            "@com_lihaoyi_sourcecode",
        ],
    },
    "org_scalameta_fastparse_utils": {
        "artifact": "org.scalameta:fastparse-utils_2.12:1.0.1",
        "sha256": "9d8ad97778ef9aedef5d4190879ed0ec54969e2fc951576fe18746ae6ce6cfcf",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_io": {
        "artifact": "org.scalameta:io_2.12:4.14.2",
        "sha256": "b83fc2597bed1c0345578f0ff37ee411f13e4b9bba1cc3a429d30d9944bd88f7",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_mdoc_parser": {
        "artifact": "org.scalameta:mdoc-parser_2.12:2.8.0",
        "sha256": "5531f16c50e5ddc9e4cbe1e1aaf79c52a9a64a1c35da70abf62a30a7faddc9ea",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_metaconfig_core": {
        "artifact": "org.scalameta:metaconfig-core_2.12:0.17.0",
        "sha256": "5f9b14da8a2ba23d31556c3b6ad98ac1d0eaccd880504ab9178b6e5eeab5b61e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scala_lang_modules_scala_collection_compat",
            "@org_scalameta_metaconfig_pprint",
            "@org_typelevel_paiges_core",
        ],
    },
    "org_scalameta_metaconfig_pprint": {
        "artifact": "org.scalameta:metaconfig-pprint_2.12:0.17.0",
        "sha256": "6931549d911bc96135972f2c0f969ddf175734f89f528dbec545a1af585367e4",
        "deps": [
            "@com_lihaoyi_fansi",
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "org_scalameta_metaconfig_typesafe_config": {
        "artifact": "org.scalameta:metaconfig-typesafe-config_2.12:0.17.0",
        "sha256": "82d90ac880bd879bcdf10b979d614104dee60268ce41a1fcf75956828ad8a9de",
        "deps": [
            "@com_typesafe_config",
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_metaconfig_core",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.12:4.14.2",
        "sha256": "6b20d665db1c275148934d3e4af119c4306b91e14ababa6382927027272d0936",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_config": {
        "artifact": "org.scalameta:scalafmt-config_2.12:3.10.2",
        "sha256": "84e779f967ad9a9ed8979fa681f15ed38bde2732a942a9340d3380d85c65fc56",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_metaconfig_core",
            "@org_scalameta_metaconfig_typesafe_config",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.12:3.10.2",
        "sha256": "4a4b7dfc7f9a874840e622f51b8d345a1fcaf73cb09ca59ca1fa8f3a117a9a4f",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_mdoc_parser",
            "@org_scalameta_scalafmt_config",
            "@org_scalameta_scalafmt_macros",
            "@org_scalameta_scalafmt_sysops",
        ],
    },
    "org_scalameta_scalafmt_macros": {
        "artifact": "org.scalameta:scalafmt-macros_2.12:3.10.2",
        "sha256": "3b21269bfc9913361448a3e7b3d103954e245383e652bd4251913029a7e6944b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scalameta_scalameta",
        ],
    },
    "org_scalameta_scalafmt_sysops": {
        "artifact": "org.scalameta:scalafmt-sysops_2.12:3.10.2",
        "sha256": "82f8d0bfdc5b4fd83eeb0276c6c777e4d1eaa4f09b969be3df6a44812eb57fda",
        "deps": [
            "@com_github_bigwheel_util_backports",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.12:4.14.2",
        "sha256": "d59ceca108c5d87789672478c17b96578cff47e1a0fc920ea611a853cd060008",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_semanticdb_scalac": {
        "artifact": "org.scalameta:semanticdb-scalac_2.12.20:4.13.10",
        "sha256": "8190bf1b959901b91d9a4539b67ec5ceb022b7cf529db5b894d2d6042bb15369",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.12:4.14.2",
        "sha256": "a93e3d8a95cca47c839e56961554db9463ddcc25e3ffc399b92a6c2f94d14b54",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
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
        "artifact": "org.typelevel:cats-core_2.12:0.9.0",
        "sha256": "3ca705cba9dc0632e60477d80779006f8c636c0e2e229dda3410a0c314c1ea1d",
    },
    "org_typelevel_kind_projector": {
        "artifact": "org.typelevel:kind-projector_2.12.20:0.13.4",
        "sha256": "56777b7286c6013c6761fba538abc37274c7aa902a00933acd1e6f6e52d5268a",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.12:0.4.4",
        "sha256": "bffacf6bfc346d4822b2c18e62fb39f18418beeb41f849761ff9ac1c20a9aea9",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
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
        "artifact": "com.thesamet.scalapb:compilerplugin_2.12:1.0.0-alpha.3",
        "sha256": "f0a3dc37259776c0268c8e35a36419194d162ed1efb1eb065edb74caa3f6d77a",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
            "@scala_proto_rules_scalapb_protoc_gen",
        ],
    },
    "scala_proto_rules_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.12:1.0.0-alpha.3",
        "sha256": "8bde73d646d124927649e4a2ff0d087ea08395df62b20f7a368074dce59bc7d3",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "scala_proto_rules_scalapb_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.12:0.9.9",
        "sha256": "dcfb2c0ec742e1e2c89ed43d7ed9e3b105a0c48af0a6c1d381d1077ffe55aa08",
        "deps": [
            "@dev_dirs_directories",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "scala_proto_rules_scalapb_protoc_gen": {
        "artifact": "com.thesamet.scalapb:protoc-gen_2.12:0.9.9",
        "sha256": "3e1e6305b4091e0579ca935ec7341770af34ed34c14e3f53b9485704fe15c7ad",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@scala_proto_rules_scalapb_protoc_bridge",
        ],
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.12:1.0.0-alpha.3",
        "sha256": "6196d9ed08e07830542971a48971cc2fba02186930d10c8623884115f0135fd4",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
            "@scala_proto_rules_scalapb_lenses",
        ],
    },
    "scala_proto_rules_scalapb_runtime_grpc": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime-grpc_2.12:1.0.0-alpha.3",
        "sha256": "d6f1a71e7acdd47eb0b7367d32a5b2d930c3fe1b75e9b8b641b449c1ef0ebda2",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
            "@scala_proto_rules_grpc_protobuf",
            "@scala_proto_rules_grpc_stub",
            "@scala_proto_rules_scalapb_runtime",
        ],
    },
}
