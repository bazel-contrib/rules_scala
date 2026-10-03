package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.WorkerProtocol;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;

/**
 * A base for JVM workers.
 *
 * <p>This supports regular workers as well as persisent workers. It does not (yet) support
 * multiplexed workers.
 *
 * <p>Worker implementations should implement the `Worker.Interface` interface and provide a main
 * method that calls `Worker.workerMain`.
 *
 * <p>The persistent-worker loop hijacks {@link System#out} / {@link System#err} into an
 * in-memory buffer so the bytes can ride back in {@code WorkResponse.output}. The original
 * {@code System.err} is snapshotted into {@code realStdErr} so a JVM shutdown hook can flush
 * the captured tail of the in-flight request onto it on an abnormal exit that still runs
 * shutdown hooks: {@link System#exit} from inside {@code work()}, uncaught {@link Throwable}
 * unwinding the main thread, or signal-induced shutdown (e.g. SIGTERM). It does NOT cover
 * SIGKILL, native JVM crashes, or {@link Runtime#halt} — those terminate without running hooks
 * and the captured tail is unavoidably lost.
 */
public final class Worker {

  public static interface Interface {
    public void work(String[] args) throws Exception;


    public abstract class WorkerException extends RuntimeException {
      public WorkerException(String message) {
        super(message);
      }
      public WorkerException(String message, Throwable cause) {
        super(message, cause);
      }
    }
  }

  /**
   * The entry point for all workers.
   *
   * <p>This should be the only thing called by a main method in a worker process.
   */
  public static void workerMain(String workerArgs[], Interface workerInterface) throws Exception {
    if (workerArgs.length > 0 && workerArgs[0].equals("--persistent_worker")) {
      persistentWorkerMain(workerInterface);
    } else {
      ephemeralWorkerMain(workerArgs, workerInterface);
    }
  }

  /** The main loop for persistent worker processes */
  private static void persistentWorkerMain(Interface workerInterface) {
    final InputStream stdin = System.in;
    final PrintStream stdout = System.out;
    // Snapshot the worker server's real stderr (FD 2) before any hijack so the
    // shutdown hook can write to a stream the server is actually reading.
    final PrintStream realStdErr = System.err;
    final ByteArrayOutputStream outStream = new SmartByteArrayOutputStream();
    final PrintStream out = new PrintStream(outStream);

    // Published from the main loop to the shutdown-hook thread so the
    // abnormal-exit diagnostic can name what was running when the JVM died.
    final AtomicReference<String> inFlightArgv = new AtomicReference<>(null);
    final AtomicLong requestsCompleted = new AtomicLong(0);
    final String prefix = "[rules_scala-pw pid=" + ProcessHandle.current().pid() + "] ";
    // Set RULES_SCALA_WORKER_TRACE=1 (or any non-empty/non-zero/non-false value) to emit
    // per-request start/end markers + lifecycle banners to the worker server's real stderr.
    // Off by default — these are debugging output, not production logging.
    final boolean trace = isTraceEnabled();

    final Thread shutdownHook =
        installAbnormalExitHook(
            realStdErr, outStream, out, inFlightArgv, requestsCompleted, prefix);

    if (trace) {
      realStdErr.println(prefix + "start");
      realStdErr.flush();
    }

    // We can't support stdin, so assign it to read from an empty buffer
    System.setIn(new ByteArrayInputStream(new byte[0]));

    System.setOut(out);
    System.setErr(out);

    try {
      while (true) {
        try {
          WorkerProtocol.WorkRequest request =
              WorkerProtocol.WorkRequest.parseDelimitedFrom(stdin);

          // The request will be null if stdin is closed.  We're
          // not sure if this happens in TheRealWorld™ but it is
          // useful for testing (to shut down a persistent
          // worker process).
          if (request == null) {
            break;
          }

          List<String> argList = request.getArgumentsList();
          String argvSnap = summarizeArgv(argList);
          inFlightArgv.set(argvSnap);
          long reqNum = requestsCompleted.get() + 1;
          if (trace) {
            realStdErr.println(prefix + "req=" + reqNum + " argv=" + argvSnap);
            realStdErr.flush();
          }

          int code = 0;

          try {
            String[] workerArgs = stringListToArray(argList);
            String[] args = expandArgsIfArgsfile(workerArgs);
            workerInterface.work(args);
          } catch (Exception e) {
            if (e instanceof Interface.WorkerException) System.err.println(e.getMessage());
            else e.printStackTrace();
            code = 1;
          }

          WorkerProtocol.WorkResponse.newBuilder()
              .setExitCode(code)
              .setOutput(outStream.toString())
              .setRequestId(request.getRequestId())
              .build()
              .writeDelimitedTo(stdout);

          if (trace) {
            realStdErr.println(
                prefix
                    + "req="
                    + reqNum
                    + " done exit="
                    + code
                    + " out_bytes="
                    + outStream.size());
            realStdErr.flush();
          }
          requestsCompleted.incrementAndGet();

        } catch (IOException e) {
          // for now we swallow IOExceptions when
          // reading/writing proto
        } finally {
          out.flush();
          outStream.reset();
          inFlightArgv.set(null);
          System.gc();
        }
      }
    } finally {
      // Loop exited cleanly (stdin EOF). Detach the abnormal-exit hook so it
      // doesn't fire during the JVM's normal shutdown sequence.
      try {
        Runtime.getRuntime().removeShutdownHook(shutdownHook);
      } catch (IllegalStateException ignored) {
        // JVM is already in shutdown; the hook will fire on its own.
      }
      System.setIn(stdin);
      System.setOut(stdout);
      System.setErr(realStdErr);
      if (trace) {
        realStdErr.println(prefix + "stop requests=" + requestsCompleted.get());
        realStdErr.flush();
      }
    }
  }

  private static boolean isTraceEnabled() {
    String v = System.getenv("RULES_SCALA_WORKER_TRACE");
    if (v == null || v.isEmpty()) return false;
    return !v.equals("0") && !v.equalsIgnoreCase("false");
  }

  /**
   * Installs a JVM shutdown hook that, on abnormal exit, flushes the persistent worker's captured
   * stdout/stderr tail onto the worker server's real stderr — so a {@link System#exit} from
   * inside {@code work()} or an uncaught {@link Throwable} surfaces with enough context for an
   * operator to identify the failing action instead of just an EOF on the worker protocol pipe.
   *
   * <p>Concurrency note: when {@link System#exit} fires from inside {@code work()} the main
   * thread is still writing to {@code outStream} while the hook reads from it. Both sides go
   * through {@link ByteArrayOutputStream}'s synchronized methods, so the worst case is a
   * partial-buffer read — still better than no diagnostic at all.
   */
  private static Thread installAbnormalExitHook(
      PrintStream realStdErr,
      ByteArrayOutputStream outStream,
      PrintStream out,
      AtomicReference<String> inFlightArgv,
      AtomicLong requestsCompleted,
      String prefix) {
    final int maxTailBytes = 64 * 1024;
    Thread hook =
        new Thread(
            () -> {
              try {
                out.flush();
                byte[] buf = outStream.toByteArray();
                int total = buf.length;
                int start = total > maxTailBytes ? total - maxTailBytes : 0;
                int len = total - start;
                String inFlight = inFlightArgv.get();

                realStdErr.println();
                realStdErr.println(prefix + "abnormal-exit diagnostic");
                realStdErr.println(prefix + "  requests_completed=" + requestsCompleted.get());
                realStdErr.println(
                    prefix + "  in_flight_argv=" + (inFlight == null ? "(idle)" : inFlight));
                if (start > 0) {
                  realStdErr.println(
                      prefix
                          + "  captured_buffer_bytes="
                          + total
                          + " (showing last "
                          + maxTailBytes
                          + ")");
                } else {
                  realStdErr.println(prefix + "  captured_buffer_bytes=" + total);
                }
                if (len > 0) {
                  realStdErr.println(prefix + "---- captured tail begin ----");
                  realStdErr.write(buf, start, len);
                  if (buf[total - 1] != '\n') {
                    realStdErr.println();
                  }
                  realStdErr.println(prefix + "---- captured tail end ----");
                }
                realStdErr.flush();
              } catch (Throwable t) {
                // Hooks must not propagate. Best-effort surface so a bug here isn't silent.
                try {
                  realStdErr.println(prefix + "abnormal-exit hook itself failed: " + t);
                  t.printStackTrace(realStdErr);
                  realStdErr.flush();
                } catch (Throwable ignored) {
                  // Give up.
                }
              }
            },
            "rules_scala-worker-abnormal-exit");
    Runtime.getRuntime().addShutdownHook(hook);
    return hook;
  }

  /** The single pass runner for ephemeral (non-persistent) worker processes */
  private static void ephemeralWorkerMain(String workerArgs[], Interface workerInterface)
      throws Exception {
    String[] args = expandArgsIfArgsfile(workerArgs);
    workerInterface.work(args);
  }

  private static String[] expandArgsIfArgsfile(String[] allArgs) throws IOException {
    if (allArgs.length == 1 && allArgs[0].startsWith("@")) {
        return stringListToArray(
                Files.readAllLines(
                  Paths.get(allArgs[0].substring(1)),
                  StandardCharsets.UTF_8)
                );

    } else {
      return allArgs;
    }
  }

  /**
   * Produces a printable argv summary up to ~256 characters. Used in start/end markers and the
   * shutdown-hook diagnostic; the goal is enough context for an operator to identify the action
   * by eyeball, not a complete record.
   */
  static String summarizeArgv(List<String> args) {
    if (args.isEmpty()) {
      return "(empty)";
    }
    StringBuilder sb = new StringBuilder();
    int budget = 256;
    int consumed = 0;
    for (String a : args) {
      if (budget <= 0) break;
      if (consumed > 0) {
        sb.append(' ');
      }
      if (a.length() > budget) {
        sb.append(a, 0, budget).append("...");
        budget = 0;
      } else {
        sb.append(a);
        budget -= a.length() + 1;
      }
      consumed++;
    }
    if (consumed < args.size()) {
      sb.append(" ...(+").append(args.size() - consumed).append(" more)");
    }
    return sb.toString();
  }

  /**
   * A ByteArrayOutputStream that sometimes shrinks its internal buffer during calls to `reset`.
   *
   * <p>In contrast, a regular ByteArrayOutputStream will only ever grow its internal buffer.
   *
   * <p>For an example of subclassing a ByteArrayOutputStream, see Spring's
   * ResizableByteArrayOutputStream:
   * https://github.com/spring-projects/spring-framework/blob/master/spring-core/src/main/java/org/springframework/util/ResizableByteArrayOutputStream.java
   */
  static class SmartByteArrayOutputStream extends ByteArrayOutputStream {
    // ByteArrayOutputStream's defualt Size is 32, which is extremely small
    // to capture stdout from any worker process. We choose a larger default.
    private static final int DEFAULT_SIZE = 256;

    public SmartByteArrayOutputStream() {
      super(DEFAULT_SIZE);
    }

    public boolean isOversized() {
      return this.buf.length > DEFAULT_SIZE;
    }

    @Override
    public void reset() {
      super.reset();
      // reallocate our internal buffer if we've gone over our
      // desired idle size
      if (this.isOversized()) {
        this.buf = new byte[DEFAULT_SIZE];
      }
    }
  }

  private static String[] stringListToArray(List<String> argList) {
    int numArgs = argList.size();
    String[] args = new String[numArgs];
    for (int i = 0; i < numArgs; i++) {
      args[i] = argList.get(i);
    }
    return args;
  }
}
