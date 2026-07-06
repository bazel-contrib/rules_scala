"""Maven artifact repository metadata.

Mostly generated and updated by scripts/create_repository.py.
"""

scala_version = "2.12.21"

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
        "artifact": "com.lihaoyi:fansi_2.12:0.5.1",
        "sha256": "57bd285ff4c4aa706fbe26e08e344881b0fc05a1a7ef8928385fab9b5208de81",
        "srcjar_sha256": "125a6a437cb07ac97b7c71c71969978ac740e9c4154fbf60105e2d681f37b3a0",
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
        "srcjar_sha256": "3e9865263f3968b22ee5ca2ccc75ae4aaa73115357cc3cee938088689a1c17b6",
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
        "artifact": "org.scala-lang:scala-compiler:2.12.21",
        "sha256": "fb1bb6b0d7e8e922f03b5294ef0af23b9d2bd1cde6819ecb820c57210db4548e",
        "srcjar_sha256": "4392a5faa59928b164e3f7548234a3b2804dcd407b16214d01176a7f1f63a5f1",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scala_xml",
        ],
    },
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:2.12.21",
        "sha256": "e2f4040c95cc4dd1cfeaae38bdde596e4b36933632451efa7d8564c6a359510c",
        "srcjar_sha256": "8c017a4ac49179a6d9c0e5300b38f20ec44b8f80d6b00018a5e3034c46365e10",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.12:2.4.0",
        "sha256": "23a8d4ddbb7d116dc7a4c41a33f362e5f908cb6b57210c6ed38e61a6c8e383ea",
        "srcjar_sha256": "6e93bce718c90dc9bbf018dbdb571f03afe3f3b47e7c94c85894bbfe9ca15720",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:2.12.21",
        "sha256": "8b91a08ba69a0564689793e732f06768d0914ec9e90fa8c3d1b55c5bf4600c14",
        "srcjar_sha256": "f690f8e748bd388a3a2535fb25990cae1c15fe15a98360dd4028905b7500f991",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.12:2.3.0",
        "sha256": "4932c56a2d5aae77ae8d7ac6bed1f21d48268fdbac8b4e5f3ca5196ad10fd93e",
        "srcjar_sha256": "bb93b2fdcd36ebd3e7e6e6de961cd2a4ead3815c9565c7be5cad860cf3d8c81c",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.12:3.2.19",
        "sha256": "a50a3248208b25e9797c447709fe4276026510beae01e82366f405a66d9a8d57",
        "srcjar_sha256": "1e144d19da246a2401b4c7d1254be4e9b599f2f03a55bb44e2c23e9a3ddcbb50",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.12:3.2.19",
        "sha256": "9f7dc750bbd6eeb52f0d8bc7c542ace46da9efdca0128a5a92769a448e065a62",
        "srcjar_sha256": "9e51badec41f488cebd1f74d25c8a3bdac4161b54649122c59e724fabc04e889",
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
        "srcjar_sha256": "3e4471354f33698d9eeef51813f45747a9657ccc0dc615e284890936366f70a7",
    },
    "io_bazel_rules_scala_scalatest_core": {
        "artifact": "org.scalatest:scalatest-core_2.12:3.2.19",
        "sha256": "57b683ac16954fae147182bae9619a1d3070286bc2febc18c059600dd2885a99",
        "srcjar_sha256": "5de8c0e06f704fd30430ba8467f86e1a9f20276ca2a24b4e06e3a1ba86022049",
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
        "srcjar_sha256": "f1a7f1682adef04bd66d0c711e706327f1c6fb40f6c80599af5c9f0a6212b34c",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_2.12:3.2.19",
        "sha256": "a7173e04338830b03cb366839bd03deb1765e06bacd3414c306548ba03280016",
        "srcjar_sha256": "71103b6f9e752770253b167ab8cfcb1adbd46f8ecae804e68c003f1348d683ba",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_2.12:3.2.19",
        "sha256": "b3974fa6f1f4b97b583ac94911adbb5b78a48a5c06101860d015f0e9df0e0131",
        "srcjar_sha256": "1f56dd506a12425a11e2b837a0416d7595160a57d042bed8e928ecc7ca13fce4",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_2.12:3.2.19",
        "sha256": "008cad5f68215028f3120ce24cd8f40ee435260d14455143884da8f66496c7b2",
        "srcjar_sha256": "3f2922d60b0945c331826d99f0c225f74e3a40785d4d287e854145aff140ee6d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_2.12:3.2.19",
        "sha256": "24646029011aa0528cbba3d14320167f16604225eb72eaf95521134ac82944e6",
        "srcjar_sha256": "aee8f9050f855de8f6d23a0c7fd8307bd648cd2f8e08cba60183577f28060e56",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_2.12:3.2.19",
        "sha256": "4ccea10ecf3f1ecfd16d7cab4da2dbec965da1cebc5e956aeddc814e27845ba8",
        "srcjar_sha256": "55a2d43256f955e108196097ffc2e5d2d7224723a0d68fd4f95ef3287d26aa1f",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_2.12:3.2.19",
        "sha256": "1048196692ce8ad06fed0e6fb41ce87d6b205646be3c2a78d3654ce90a9d5bc5",
        "srcjar_sha256": "e0c385ea2abcdd51384dbee66384ca97f0559c2ed25217b2d7fb30ac35f79635",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_2.12:3.2.19",
        "sha256": "e879ad96f7c5ab558994b34d9a96cf50dc6b32f7c34e7df0586d72ba6c3cbddc",
        "srcjar_sha256": "ac2a920f304e957a1feff3f449dc556be9bd74b85891a901322691a34be5c758",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_propspec": {
        "artifact": "org.scalatest:scalatest-propspec_2.12:3.2.19",
        "sha256": "7482f4b139e870f14b8d32f4ad57a11846d7d5e7ea6448aebd34416bee7c2749",
        "srcjar_sha256": "5c58e1ba8bc1f45d394fcab3ef6f9c62cb9531874ccd6b2dcbbb723473a22d8e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_refspec": {
        "artifact": "org.scalatest:scalatest-refspec_2.12:3.2.19",
        "sha256": "3c0ae4964bd2f56fd71404480724bf2ee94d081187ddf2704b603f897f1faa16",
        "srcjar_sha256": "76b16ccd3ab49e4e0cf3dd242931ce3979c3c51ac048865e8648806e3470ec5e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_2.12:3.2.19",
        "sha256": "36e8fa4935945c913c6989e98050355814c2f6ee96b0b350da3cc76e471eb14f",
        "srcjar_sha256": "6768f1c650b1fb3c5525c10f766c15bc177e855b0b31607c2d2afb92378725fb",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_wordspec": {
        "artifact": "org.scalatest:scalatest-wordspec_2.12:3.2.19",
        "sha256": "ff5c1ebe03dbf728f6d2a698b8757d940cbeae0102b4ba3301c4ef7447033e18",
        "srcjar_sha256": "bcb3e6a496e87891e79ec0fee6063e654f79bf3407d4294ecacf756a1550d850",
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
        "artifact": "org.codehaus.mojo:animal-sniffer-annotations:1.26",
        "sha256": "342f4d815eae69bb980620d0a622862709be37d38f47577675b42c739a962da9",
        "srcjar_sha256": "56d2844b620f4742f4b1c47d83357745b39cb26c45423d1249066c15eca31a86",
    },
    "org_jspecify_jspecify": {
        "artifact": "org.jspecify:jspecify:1.0.0",
        "sha256": "1fad6e6be7557781e4d33729d49ae1cdc8fdda6fe477bb0cc68ce351eafdfbab",
        "srcjar_sha256": "adf0898191d55937fb3192ba971826f4f294292c4a960740f3c27310e7b70296",
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.12:2.14.0",
        "sha256": "40d7c1719db7940a7101509dff407f1ff67baf01abd1f40547b04077d94a92e5",
        "srcjar_sha256": "3135ab55ffc54fa4f8dc69dd465d6484c18cdf5578ef1de722ccbc2de4094093",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.12.21",
        "sha256": "e33e12ad739cd70db536b5e305a07d3b081490863f0db67a515d41585c087605",
        "srcjar_sha256": "806fb8d5ee8ff8bed6a2ed60162986aa634b9f318261e0815c467817d9e5d143",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
        ],
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.12:4.15.0",
        "sha256": "c0aa97e75e76ea7b8b0b8b184e88c2026404fc1019cbb8654033b765242a8619",
        "srcjar_sha256": "063f363bf298586d5b432b995c0d28e0980f8c92dc8cda08717dc0313d974829",
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
        "artifact": "org.scalameta:io_2.12:4.15.0",
        "sha256": "181790fcd968f66f1e3a14a456817f7af5586ed09348d19e91c54be2a19c91e9",
        "srcjar_sha256": "9078cf60f01f8f226d6f098f59354f7e118e4aba15e78e7f45a4fa90177bc468",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_mdoc_parser": {
        "artifact": "org.scalameta:mdoc-parser_2.12:2.8.2",
        "sha256": "f90e3b1398b72f50dbb4bbc58dacf7775202e353379837db836258f7f21e6b30",
        "srcjar_sha256": "62bcd8509f7e0fc9e148c7668f86765c02e27c87acedf077306e1ff86789c32b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_metaconfig_core": {
        "artifact": "org.scalameta:metaconfig-core_2.12:0.18.2",
        "sha256": "4fa925ea1cf2c5d1025650173dcbc5225e1ca6bc941f705b743060be59e51472",
        "srcjar_sha256": "b968cd04a80098a6e308e522733b984e7529c0b5d107a89e9641236f469a5630",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scala_lang_modules_scala_collection_compat",
            "@org_scalameta_metaconfig_pprint",
            "@org_typelevel_paiges_core",
        ],
    },
    "org_scalameta_metaconfig_pprint": {
        "artifact": "org.scalameta:metaconfig-pprint_2.12:0.18.2",
        "sha256": "f7f14cc9ed379e672954f0295bf52200ba275ac0e89a44fd75afe0e33e07d048",
        "srcjar_sha256": "498254a90b97ff04a4d23a17486194ab3d49fb378ecb3d2eefa9a7691951035f",
        "deps": [
            "@com_lihaoyi_fansi",
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "org_scalameta_metaconfig_typesafe_config": {
        "artifact": "org.scalameta:metaconfig-typesafe-config_2.12:0.18.2",
        "sha256": "81b23cce37e94fb0d76c5583195daf4194322c9ba6aed4bb6ce845c374bca615",
        "srcjar_sha256": "f769fafc6a7158a2dda3d3c69742f4a0b209affc278c011872a95230295ee485",
        "deps": [
            "@com_typesafe_config",
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_metaconfig_core",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.12:4.15.0",
        "sha256": "665afe0636a0de59a755d30823e8e423f31d705a5a84fa95693c993ae4aadb02",
        "srcjar_sha256": "b2053e1f57aced06d167be5e2de71695c2bd9c2b0337293b7aa27731f3d829e3",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_config": {
        "artifact": "org.scalameta:scalafmt-config_2.12:3.10.7",
        "sha256": "d4392d112ef61b057d7225d3028f857673736c05e6e793534a17c6e50a9613e9",
        "srcjar_sha256": "78e1cc11f7d9557d526151219f33c3f7042f207ce30bd4bf8122cbe574663dc4",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_metaconfig_core",
            "@org_scalameta_metaconfig_typesafe_config",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.12:3.10.7",
        "sha256": "2b3501e228f445d21d2398de09f4b53229fa22b01a5ea8a0ee617c055ebb790e",
        "srcjar_sha256": "e8be6c46aaa41a0dedb2608daf43f594bfd2ff142b7828f917e75d082e8f140b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_mdoc_parser",
            "@org_scalameta_scalafmt_config",
            "@org_scalameta_scalafmt_macros",
            "@org_scalameta_scalafmt_sysops",
        ],
    },
    "org_scalameta_scalafmt_macros": {
        "artifact": "org.scalameta:scalafmt-macros_2.12:3.10.7",
        "sha256": "18e31babafc871b8dc37c69b48acac9774a4601af2b549ece421ae1dd7b15897",
        "srcjar_sha256": "e27cbf49845418c9f4d1dd94902ab23b6d58dbe9955ec6c3865b8bb631bf5f81",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scalameta_scalameta",
        ],
    },
    "org_scalameta_scalafmt_sysops": {
        "artifact": "org.scalameta:scalafmt-sysops_2.12:3.10.7",
        "sha256": "eea65b5e6a6da8c263016fdd31000f3e336a0ddeba502150f96f384ad9cc865d",
        "srcjar_sha256": "2b3a5f034e5ea75af5e2e3965c88f93714d3a69a4f37f4553ee5d8ea80c3765d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.12:4.15.0",
        "sha256": "449a86398ab168445dcdb238525c6cfa447ebfeaedd7f9639474f78de5a77277",
        "srcjar_sha256": "6fc8c041be1923dc147d103d32b627d5e02dbc89580447c0c129912406b8855d",
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
        "artifact": "org.scalameta:trees_2.12:4.15.0",
        "sha256": "ef7fdde32e874b69f34022e0685bba7d3d51a598e9adaf6457719a429c223753",
        "srcjar_sha256": "e27586660bde1c0bee2a99eca5a4adf47c090813cda802afc53bd2d11f900efd",
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
        "srcjar_sha256": "15be9c8170818417331baf846d931d5daaab2699c6417af6feb56fbee66f07d8",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
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
        "artifact": "com.thesamet.scalapb:compilerplugin_2.12:1.0.0-alpha.3",
        "sha256": "f0a3dc37259776c0268c8e35a36419194d162ed1efb1eb065edb74caa3f6d77a",
        "srcjar_sha256": "052b989fe8dc5d49a9df3f7aa813fe2e6e5f02ea3b5e629d4d478c11236cfc20",
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
        "srcjar_sha256": "fd2cd8fe024f7dacfe736f549f70b81de0a0526c57502e8660775b837becf5e2",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "scala_proto_rules_scalapb_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.12:0.9.9",
        "sha256": "dcfb2c0ec742e1e2c89ed43d7ed9e3b105a0c48af0a6c1d381d1077ffe55aa08",
        "srcjar_sha256": "c24b3ec355846168fce61b2d1ce0d7cee49079d799a1411b1cdea0d364c6794c",
        "deps": [
            "@dev_dirs_directories",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "scala_proto_rules_scalapb_protoc_gen": {
        "artifact": "com.thesamet.scalapb:protoc-gen_2.12:0.9.9",
        "sha256": "3e1e6305b4091e0579ca935ec7341770af34ed34c14e3f53b9485704fe15c7ad",
        "srcjar_sha256": "6c4d621291ee88946049fc730c4ee8910d9ef6d7a1545297a50e8879c08b47b6",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@scala_proto_rules_scalapb_protoc_bridge",
        ],
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.12:1.0.0-alpha.3",
        "sha256": "6196d9ed08e07830542971a48971cc2fba02186930d10c8623884115f0135fd4",
        "srcjar_sha256": "e51dea15f87bcacd9c813ecffb78c6d813b19d8f7ce02c36940de8ce1be72118",
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
