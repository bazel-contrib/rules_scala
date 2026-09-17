package foo

import org.openjdk.jmh.annotations.Benchmark

class JvmFlagsBenchmark {
  @Benchmark
  def readsJvmFlagBenchmark: String = {
    val marker = System.getProperty("test.jmh.marker")
    if (marker == null) {
      throw new IllegalStateException("jvm_flags did not reach the benchmark JVM")
    }
    marker
  }
}
