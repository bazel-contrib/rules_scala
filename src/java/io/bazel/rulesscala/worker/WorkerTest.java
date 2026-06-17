package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.WorkerProtocol;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.AfterClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

@RunWith(JUnit4.class)
public class WorkerTest {

  @Test
  public void testPersistentWorkerNoStdin() throws Exception {
    try (PersistentWorkerHelper helper = new PersistentWorkerHelper(); ) {
      WorkerProtocol.WorkRequest.newBuilder().build().writeDelimitedTo(helper.requestOut);

      final AtomicInteger result = new AtomicInteger();
      Worker.Interface worker =
          new Worker.Interface() {
            @Override
            public void work(String[] args) throws Exception {
              result.set(System.in.read());
            }
          };

      helper.runWorker(worker);
      assert (result.get() == -1);
    }
  }

  @Test
  public void testPersistentWorkerArgsfile() throws Exception {
    Path tmpFile = Files.createTempFile("testPersistentWorkerArgsfiles-args", ".txt");

    try (PersistentWorkerHelper helper = new PersistentWorkerHelper()) {
      Worker.Interface worker =
          new Worker.Interface() {
            @Override
            public void work(String[] args) {
              for (String arg : args) {
                System.out.println(arg);
              }
            }
          };

      String contents = String.join(
        System.getProperty("line.separator"),
        "line 1",
        "--flag_1",
        "some arg",
        "");  // The output will always have a line separator at the end.

      Files.write(tmpFile, contents.getBytes(StandardCharsets.UTF_8));

      WorkerProtocol.WorkRequest.newBuilder()
          .addArguments("@" + tmpFile)
          .build()
          .writeDelimitedTo(helper.requestOut);

      helper.runWorker(worker);

      WorkerProtocol.WorkResponse response =
          WorkerProtocol.WorkResponse.parseDelimitedFrom(helper.responseIn);

      assertEquals(0, response.getExitCode());
      assertEquals(contents, response.getOutput());
    } finally {
      Files.deleteIfExists(tmpFile);
    }
  }

  /** A helper to manage IO when testing a persistent worker. */
  private final class PersistentWorkerHelper implements AutoCloseable {

    public final PipedInputStream workerIn;
    public final PipedOutputStream requestOut;

    public final PipedOutputStream workerOut;
    public final PipedInputStream responseIn;

    private final InputStream stdin;
    private final PrintStream stdout;
    private final PrintStream stderr;

    public PersistentWorkerHelper() throws IOException {
      this.workerIn = new PipedInputStream();
      this.requestOut = new PipedOutputStream(workerIn);
      this.workerOut = new PipedOutputStream();
      this.responseIn = new PipedInputStream(workerOut);

      this.stdin = System.in;
      this.stdout = System.out;
      this.stderr = System.err;

      System.setIn(this.workerIn);
      System.setOut(new PrintStream(this.workerOut));
    }

    public void runWorker(Worker.Interface worker) throws Exception {
      // otherwise the worker will poll indefinitely
      this.requestOut.close();
      Worker.workerMain(new String[] {"--persistent_worker"}, worker);
    }

    public void close() {
      try {
        this.workerIn.close();
      } catch (IOException e) {
      }
      try {
        this.requestOut.close();
      } catch (IOException e) {
      }
      try {
        this.workerOut.close();
      } catch (IOException e) {
      }
      try {
        this.responseIn.close();
      } catch (IOException e) {
      }

      System.setIn(this.stdin);
      System.setOut(this.stdout);
      System.setErr(this.stderr);
    }
  }

  private static void fill(ByteArrayOutputStream baos, int amount) {
    for (int i = 0; i < amount; i++) {
      baos.write(0);
    }
  }

  @Test
  public void testBufferWriteReadAndReset() throws Exception {
    Worker.SmartByteArrayOutputStream baos = new Worker.SmartByteArrayOutputStream();
    PrintStream out = new PrintStream(baos);

    out.print("hello, world");
    assert (baos.toString("UTF-8").equals("hello, world"));
    assert (!baos.isOversized());

    fill(baos, 300);
    assert (baos.isOversized());
    baos.reset();

    out.print("goodbye, world");
    assert (baos.toString("UTF-8").equals("goodbye, world"));
    assert (!baos.isOversized());
  }

  // ---- summarizeArgv unit tests ----

  @Test
  public void testSummarizeArgvEmpty() {
    assertEquals("(empty)", Worker.summarizeArgv(Collections.emptyList()));
  }

  @Test
  public void testSummarizeArgvShortArgs() {
    assertEquals("foo bar baz", Worker.summarizeArgv(Arrays.asList("foo", "bar", "baz")));
  }

  @Test
  public void testSummarizeArgvSingleOversizeArg() {
    // A single arg longer than the 256-char budget gets truncated with a trailing "...".
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < 300; i++) sb.append('x');
    String result = Worker.summarizeArgv(Collections.singletonList(sb.toString()));
    assertTrue("expected truncation marker, got: " + result, result.endsWith("..."));
    // 256 chars of payload + "..." == 259 chars total.
    assertEquals(259, result.length());
  }

  @Test
  public void testSummarizeArgvOverflowsBudget() {
    // Many short args; budget is 256 chars, each "arg" entry is ~4 chars including separator,
    // so we should consume roughly 60-70 entries before overflow and see "...(+N more)".
    int total = 200;
    String[] args = new String[total];
    Arrays.fill(args, "arg");
    String result = Worker.summarizeArgv(Arrays.asList(args));
    assertTrue("expected overflow marker, got: " + result, result.contains("...(+"));
    assertTrue("expected 'more' suffix, got: " + result, result.endsWith(" more)"));
  }

  // ---- abnormal-exit subprocess test ----

  /**
   * Forks a JVM that runs the persistent worker with a {@code work()} body that prints markers
   * then calls {@link System#exit}, and asserts the shutdown-hook diagnostic appears on the
   * subprocess's real stderr alongside the captured tail.
   */
  @Test
  public void testAbnormalExitHookFlushesCapturedTail() throws Exception {
    SubprocessResult result =
        runHelperSubprocess(
            "abnormal-exit-helper",
            Collections.emptyMap(),
            requestStream("--my-action=//some:target"));

    assertEquals("subprocess should exit with helper-supplied code", 42, result.exitCode);
    assertTrue(
        "stderr should contain abnormal-exit header. stderr was:\n" + result.stderr,
        result.stderr.contains("abnormal-exit diagnostic"));
    assertTrue(
        "stderr should name the in-flight argv. stderr was:\n" + result.stderr,
        result.stderr.contains("in_flight_argv=--my-action=//some:target"));
    assertTrue(
        "stderr should report requests_completed=0. stderr was:\n" + result.stderr,
        result.stderr.contains("requests_completed=0"));
    assertTrue(
        "stderr should contain captured stdout marker. stderr was:\n" + result.stderr,
        result.stderr.contains("HELPER_STDOUT_MARKER_HELLO"));
    assertTrue(
        "stderr should contain captured stderr marker. stderr was:\n" + result.stderr,
        result.stderr.contains("HELPER_STDERR_MARKER_BYE"));
    assertTrue(
        "stderr should bracket the captured tail. stderr was:\n" + result.stderr,
        result.stderr.contains("---- captured tail begin ----")
            && result.stderr.contains("---- captured tail end ----"));
  }

  /** Helper-mode {@code main}: runs as the persistent worker payload in a subprocess. */
  static void abnormalExitHelperMain() throws Exception {
    Worker.Interface worker =
        new Worker.Interface() {
          @Override
          public void work(String[] args) {
            System.out.println("HELPER_STDOUT_MARKER_HELLO");
            System.err.println("HELPER_STDERR_MARKER_BYE");
            System.out.flush();
            System.err.flush();
            System.exit(42);
          }
        };
    Worker.workerMain(new String[] {"--persistent_worker"}, worker);
  }

  // ---- trace env-var subprocess test ----

  /**
   * Asserts that {@code RULES_SCALA_WORKER_TRACE=1} turns on per-request markers and lifecycle
   * banners on the worker server's real stderr; absent the env var, those lines are silent.
   */
  @Test
  public void testTraceModeEnabledByEnvVar() throws Exception {
    java.util.Map<String, String> env = new java.util.HashMap<>();
    env.put("RULES_SCALA_WORKER_TRACE", "1");
    SubprocessResult on =
        runHelperSubprocess("trace-helper", env, requestStream("--target=//some:label"));
    assertEquals(0, on.exitCode);
    assertTrue(
        "trace=on stderr should contain 'start'. stderr was:\n" + on.stderr,
        on.stderr.contains("] start"));
    assertTrue(
        "trace=on stderr should contain per-request argv. stderr was:\n" + on.stderr,
        on.stderr.contains("argv=--target=//some:label"));
    assertTrue(
        "trace=on stderr should contain per-request done. stderr was:\n" + on.stderr,
        on.stderr.contains("done exit=0"));
    assertTrue(
        "trace=on stderr should contain 'stop'. stderr was:\n" + on.stderr,
        on.stderr.contains("] stop requests=1"));

    SubprocessResult off =
        runHelperSubprocess(
            "trace-helper", Collections.emptyMap(), requestStream("--target=//some:label"));
    assertEquals(0, off.exitCode);
    assertFalse(
        "trace=off stderr should NOT contain '] start'. stderr was:\n" + off.stderr,
        off.stderr.contains("] start"));
    assertFalse(
        "trace=off stderr should NOT contain per-request markers. stderr was:\n" + off.stderr,
        off.stderr.contains("argv=--target=//some:label"));
  }

  /** Helper-mode {@code main}: handles one request, returns success, then exits cleanly. */
  static void traceHelperMain() throws Exception {
    Worker.Interface worker =
        new Worker.Interface() {
          @Override
          public void work(String[] args) {
            // No-op: we just want a successful request to drive the trace markers.
          }
        };
    Worker.workerMain(new String[] {"--persistent_worker"}, worker);
  }

  // ---- subprocess plumbing ----

  /** {@code main} entry that dispatches to the helper modes used by the subprocess tests. */
  public static void main(String[] args) throws Exception {
    if (args.length >= 1 && args[0].equals("abnormal-exit-helper")) {
      abnormalExitHelperMain();
      return;
    }
    if (args.length >= 1 && args[0].equals("trace-helper")) {
      traceHelperMain();
      return;
    }
    System.err.println("WorkerTest.main invoked with unrecognized args: " + Arrays.toString(args));
    System.exit(2);
  }

  private static byte[] requestStream(String... argv) throws IOException {
    WorkerProtocol.WorkRequest.Builder b = WorkerProtocol.WorkRequest.newBuilder();
    for (String a : argv) b.addArguments(a);
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    b.build().writeDelimitedTo(baos);
    return baos.toByteArray();
  }

  /** Captured outcome of running a helper-mode subprocess. */
  private static final class SubprocessResult {
    final int exitCode;
    final String stdout;
    final String stderr;

    SubprocessResult(int exitCode, String stdout, String stderr) {
      this.exitCode = exitCode;
      this.stdout = stdout;
      this.stderr = stderr;
    }
  }

  /**
   * Forks {@code java -cp $CLASSPATH WorkerTest <mode>}, writes the given bytes to its stdin,
   * drains stdout/stderr in parallel, waits up to 30s, and returns the captured outcome.
   * Throws on timeout.
   */
  private static SubprocessResult runHelperSubprocess(
      String mode, java.util.Map<String, String> extraEnv, byte[] stdinBytes) throws Exception {
    String javaBin = System.getProperty("java.home") + File.separator + "bin" + File.separator + "java";
    String cp = System.getProperty("java.class.path");
    ProcessBuilder pb =
        new ProcessBuilder(javaBin, "-cp", cp, "io.bazel.rulesscala.worker.WorkerTest", mode);
    pb.environment().putAll(extraEnv);
    Process p = pb.start();

    ByteArrayOutputStream outBuf = new ByteArrayOutputStream();
    ByteArrayOutputStream errBuf = new ByteArrayOutputStream();
    Thread stdoutDrain = drain(p.getInputStream(), outBuf, "stdout-drain");
    Thread stderrDrain = drain(p.getErrorStream(), errBuf, "stderr-drain");

    try (OutputStream toChild = p.getOutputStream()) {
      toChild.write(stdinBytes);
      toChild.flush();
      // For trace-helper we close stdin so the worker loop exits cleanly after one request.
      // For abnormal-exit-helper the subprocess calls System.exit before reading further,
      // so closing is a no-op (the OS pipe is torn down on exit).
    }

    if (!p.waitFor(30, TimeUnit.SECONDS)) {
      p.destroyForcibly();
      throw new AssertionError("subprocess did not exit within 30s; mode=" + mode);
    }
    stdoutDrain.join(5000);
    stderrDrain.join(5000);

    return new SubprocessResult(
        p.exitValue(),
        outBuf.toString(StandardCharsets.UTF_8),
        errBuf.toString(StandardCharsets.UTF_8));
  }

  private static Thread drain(InputStream in, ByteArrayOutputStream into, String name) {
    Thread t =
        new Thread(
            () -> {
              try {
                in.transferTo(into);
              } catch (IOException ignored) {
                // Stream closed when the subprocess exits; nothing to do.
              }
            },
            name);
    t.setDaemon(true);
    t.start();
    return t;
  }

  @AfterClass
  public static void teardown() {
  }

  // Copied/modified from Bazel's MoreAsserts
  //
  // Note: this goes away soon-ish, as JUnit 4.13 was recently
  // released and includes assertThrows
  public static <T extends Throwable> T assertThrows(
      Class<T> expectedThrowable, ThrowingRunnable runnable) {
    try {
      runnable.run();
    } catch (Throwable actualThrown) {
      if (expectedThrowable.isInstance(actualThrown)) {
        @SuppressWarnings("unchecked")
        T retVal = (T) actualThrown;
        return retVal;
      } else {
        throw new AssertionError(
            String.format(
                "expected %s to be thrown, but %s was thrown",
                expectedThrowable.getSimpleName(), actualThrown.getClass().getSimpleName()),
            actualThrown);
      }
    }
    String mismatchMessage =
        String.format(
            "expected %s to be thrown, but nothing was thrown", expectedThrowable.getSimpleName());
    throw new AssertionError(mismatchMessage);
  }

  // see note on assertThrows
  public interface ThrowingRunnable {
    void run() throws Throwable;
  }
}
