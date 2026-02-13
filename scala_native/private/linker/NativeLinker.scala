package scala.scalanative.bazel

import java.io.File
import java.nio.file.{Files, Path, Paths}

import scala.concurrent._
import scala.util.{Failure, Success, Try}

import scala.scalanative.build._
import scala.scalanative.util.Scope

/**
 * A tool that invokes the Scala Native linker to produce a native binary.
 *
 * It takes NIR jars (classpath), a main class, and an output directory,
 * then runs the full Scala Native pipeline: link → optimize → codegen → clang.
 */
object NativeLinker {
  def main(args: Array[String]): Unit = {
    val exitCode = Try(parseArgs(args))
      .map(link)
    match {
      case Success(_) => 0
      case Failure(e) =>
        System.err.println(s"Scala Native linking failed: ${e.getMessage}")
        e.printStackTrace(System.err)
        1
    }
    System.exit(exitCode)
  }

  case class LinkerOpts(
    mainClass: String,
    outputDir: Path,
    classpath: Seq[Path],
    workDir: Path,
    moduleName: String,
    clang: Path,
    clangPP: Path,
    linkingOptions: Seq[String]
  )

  def parseArgs(args: Array[String]): LinkerOpts = {
    var mainClass: String = null
    var outputDir: Path = null
    var classpath: Seq[Path] = Seq.empty
    var workDir: Path = Paths.get(".")
    var moduleName: String = "main"
    var clang: String = null
    var clangPP: String = null
    var linkingOptions: Seq[String] = Seq.empty

    var i = 0
    while (i < args.length) {
      args(i) match {
        case "--main" =>
          mainClass = args(i + 1)
          i += 2
        case "--output" =>
          outputDir = Paths.get(args(i + 1))
          i += 2
        case "--cp" =>
          classpath = args(i + 1).split(File.pathSeparator).map(Paths.get(_)).toSeq
          i += 2
        case "--workdir" =>
          workDir = Paths.get(args(i + 1))
          i += 2
        case "--module_name" =>
          moduleName = args(i + 1)
          i += 2
        case "--clang" =>
          clang = args(i + 1)
          i += 2
        case "--clang++" =>
          clangPP = args(i + 1)
          i += 2
        case "--linking_option" =>
          linkingOptions = linkingOptions :+ args(i + 1)
          i += 2
        case other =>
          throw new IllegalArgumentException(s"Unknown argument: $other")
      }
    }

    if (mainClass == null || outputDir == null) {
      throw new IllegalArgumentException(
        "Missing required arguments. Usage: --main <class> --output <dir> --cp <classpath> [--workdir <dir>] [--module_name <name>] [--clang <path>] [--clang++ <path>]"
      )
    }

    if (clang == null || clangPP == null) {
      throw new IllegalArgumentException(
        "Scala Native cannot find clang."
      )
    }

    LinkerOpts(
      mainClass = mainClass,
      outputDir = outputDir,
      classpath = classpath,
      workDir = workDir,
      moduleName = moduleName,
      clang = Paths.get(clang),
      clangPP = Paths.get(clangPP),
      linkingOptions = linkingOptions
    )
  }

  def link(opts: LinkerOpts): Path = {
    // Ensure output and work directories exist
    Files.createDirectories(opts.outputDir)
    Files.createDirectories(opts.workDir)

    val nativeConfig = NativeConfig.empty
      .withClang(opts.clang)
      .withClangPP(opts.clangPP)
      .withGC(GC.immix)
      .withMode(Mode.debug)
      .withLTO(LTO.none)
      .withLinkStubs(true)
      .withLinkingOptions(Discover.linkingOptions() ++ opts.linkingOptions)
      .withCompileOptions(Discover.compileOptions())
      .withCppOptions(Seq("-std=c++17"))
      .withCOptions(Seq("-std=c17"))

    val config = Config.empty
      .withMainClass(Some(opts.mainClass))
      .withClassPath(opts.classpath)
      .withBaseDir(opts.outputDir)
      .withModuleName(opts.moduleName)
      .withTestConfig(false)
      .withCompilerConfig(nativeConfig)
      .withLogger(Logger.default)

    // Use Scope and a dedicated ExecutionContext for Scala Native
    Scope { implicit scope =>
      val nThreads = java.lang.Runtime.getRuntime.availableProcessors()
      implicit val ec: java.util.concurrent.ExecutorService =
        ExecutionContext.fromExecutorService(
          java.util.concurrent.Executors.newFixedThreadPool(nThreads)
        )
      val buildResult = Try(Build.buildCachedAwait(config))
      ec.shutdown()
      buildResult.get
    }
  }
}
