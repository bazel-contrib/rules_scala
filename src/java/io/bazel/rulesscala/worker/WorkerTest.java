package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.WorkerProtocol;
import java.io.IOException;
import java.io.InputStream;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import static org.junit.Assert.assertEquals;

@RunWith(JUnit4.class)
public class WorkerTest {

  @Test
  public void testPersistentWorkerNoStdin() throws Exception {
    try (PersistentWorkerHelper helper = new PersistentWorkerHelper(); ) {
      final AtomicInteger result = new AtomicInteger();
      Worker.Interface worker =
          new Worker.Interface() {
            @Override
            public void work(String[] args) throws Exception {
              result.set(System.in.read());
            }
          };

      helper.start(worker);
      WorkerProtocol.WorkRequest.newBuilder().build().writeDelimitedTo(helper.requestOut);
      WorkerProtocol.WorkResponse.parseDelimitedFrom(helper.responseIn);
      helper.stop();

      assertEquals(-1, result.get());
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

      helper.start(worker);
      WorkerProtocol.WorkRequest.newBuilder()
          .addArguments("@" + tmpFile)
          .build()
          .writeDelimitedTo(helper.requestOut);

      WorkerProtocol.WorkResponse response =
          WorkerProtocol.WorkResponse.parseDelimitedFrom(helper.responseIn);
      helper.stop();

      assertEquals(0, response.getExitCode());
      // WorkRequestHandler trims the captured System.out/System.err before
      // attaching it to WorkResponse.output, so the trailing line separator
      // is dropped on the wire.
      assertEquals(contents.trim(), response.getOutput());
    } finally {
      Files.deleteIfExists(tmpFile);
    }
  }

  /**
   * A helper to manage IO when testing a persistent worker.
   *
   * <p>{@code WorkRequestHandler} dispatches each request to its own thread and exits the
   * read loop on stdin EOF, interrupting any active request threads. Tests therefore must
   * not pre-close stdin before the request has been handled. The shape is: {@link #start}
   * the worker in a background thread, write the request via {@link #requestOut}, read
   * the response from {@link #responseIn}, then {@link #stop} (closes stdin so the
   * handler's read loop exits cleanly and joins the worker thread).
   */
  private final class PersistentWorkerHelper implements AutoCloseable {

    public final PipedInputStream workerIn;
    public final PipedOutputStream requestOut;

    public final PipedOutputStream workerOut;
    public final PipedInputStream responseIn;

    private final InputStream stdin;
    private final PrintStream stdout;
    private final PrintStream stderr;

    private Thread workerThread;
    private Exception workerError;

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

    public void start(Worker.Interface worker) {
      this.workerThread =
          new Thread(
              () -> {
                try {
                  Worker.workerMain(new String[] {"--persistent_worker"}, worker);
                } catch (Exception e) {
                  workerError = e;
                }
              },
              "test-persistent-worker");
      this.workerThread.start();
    }

    public void stop() throws Exception {
      this.requestOut.close();
      this.workerThread.join();
      if (workerError != null) {
        throw workerError;
      }
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
}
