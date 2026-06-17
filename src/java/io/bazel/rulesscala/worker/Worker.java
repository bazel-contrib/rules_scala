package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.ProtoWorkerMessageProcessor;
import com.google.devtools.build.lib.worker.WorkRequestHandler;
import com.google.devtools.build.lib.worker.WorkerProtocol;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

/**
 * A base for JVM workers.
 *
 * <p>Persistent dispatch is delegated to Bazel's official
 * {@link WorkRequestHandler}, so the worker inherits the standard contract:
 * stdout/stderr are captured per-request and shipped in {@code WorkResponse.output},
 * an uncaught {@link Error} on a request thread (e.g. {@link OutOfMemoryError})
 * is written to the original stderr before {@code System.exit(1)}, and multiplex
 * worker support is available without additional plumbing.
 *
 * <p>Worker implementations should implement {@link Interface} and provide a main
 * method that calls {@link #workerMain}.
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

  /** The main loop for persistent worker processes. */
  private static void persistentWorkerMain(Interface workerInterface) throws IOException {
    // Snapshot the original stderr before WorkRequestHandler.WorkerIO.capture()
    // redirects System.err to its per-request buffer. WorkRequestHandler writes
    // uncaught-Error diagnostics to this stream so the worker server (bb-runner /
    // local Bazel worker driver) can surface them even when the in-flight
    // WorkResponse never gets sent.
    PrintStream realStdErr = System.err;
    WorkRequestHandler handler =
        new WorkRequestHandler.WorkRequestHandlerBuilder(
                new WorkRequestHandler.WorkRequestCallback(
                    (WorkerProtocol.WorkRequest request, java.io.PrintWriter pw) -> {
                      try {
                        String[] workerArgs = stringListToArray(request.getArgumentsList());
                        String[] args = expandArgsIfArgsfile(workerArgs);
                        workerInterface.work(args);
                        return 0;
                      } catch (Interface.WorkerException e) {
                        pw.println(e.getMessage());
                        return 1;
                      } catch (Exception e) {
                        e.printStackTrace(pw);
                        return 1;
                      }
                    }),
                realStdErr,
                new ProtoWorkerMessageProcessor(System.in, System.out))
            .build();
    handler.processRequests();
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

  private static String[] stringListToArray(List<String> argList) {
    int numArgs = argList.size();
    String[] args = new String[numArgs];
    for (int i = 0; i < numArgs; i++) {
      args[i] = argList.get(i);
    }
    return args;
  }
}
