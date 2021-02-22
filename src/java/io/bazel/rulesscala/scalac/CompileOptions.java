package io.bazel.rulesscala.scalac;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CompileOptions {
  public final String outputName;
  public final String manifestPath;
  public final String[] scalaOpts;
  public final boolean printCompileTime;
  public final boolean expectJavaOutput;
  public final String[] pluginArgs;
  public final String classpath;
  public final String[] files;
  public final String[] sourceJars;
  public final String[] javaFiles;
  public final List<Resource> resourceFiles;
  public final String[] resourceJars;
  public final String[] classpathResourceFiles;
  public final String[] directJars;
  public final String[] directTargets;
  public final String[] unusedDepsIgnoredTargets;
  public final String[] indirectJars;
  public final String[] indirectTargets;
  public final String strictDepsMode;
  public final String unusedDependencyCheckerMode;
  public final String currentTarget;
  public final String statsfile;
  public final String dependencyTrackingMethod;
  public final String diagnosticsFile;
  public final boolean enableDiagnosticsReport;

  public CompileOptions(List<String> args) {
    Map<String, String> argMap = buildArgMap(args);

    outputName = getOrError(argMap, "JarOutput", "Missing required arg JarOutput");
    manifestPath = getOrError(argMap, "Manifest", "Missing required arg Manifest");

    scalaOpts = getTripleColonList(argMap, "ScalacOpts");
    printCompileTime = booleanGetOrFalse(argMap, "PrintCompileTime");
    expectJavaOutput = booleanGetOrTrue(argMap, "ExpectJavaOutput");
    pluginArgs = buildPluginArgs(getOrEmpty(argMap, "Plugins"));
    classpath = getOrError(argMap, "Classpath", "Must supply the classpath arg");
    files = getCommaList(argMap, "Files");

    javaFiles = getCommaList(argMap, "JavaFiles");

    if (!expectJavaOutput && javaFiles.length != 0) {
      throw new RuntimeException("Cannot hava java source files when no expected java output");
    }

    sourceJars = getCommaList(argMap, "SourceJars");
    resourceFiles = getResources(argMap);
    resourceJars = getCommaList(argMap, "ResourceJars");
    classpathResourceFiles = getCommaList(argMap, "ClasspathResourceSrcs");

    directJars = getCommaList(argMap, "DirectJars");
    directTargets = getCommaList(argMap, "DirectTargets");
    unusedDepsIgnoredTargets = getCommaList(argMap, "UnusedDepsIgnoredTargets");
    indirectJars = getCommaList(argMap, "IndirectJars");
    indirectTargets = getCommaList(argMap, "IndirectTargets");

    strictDepsMode = getOrElse(argMap, "StrictDepsMode", "off");
    unusedDependencyCheckerMode = getOrElse(argMap, "UnusedDependencyCheckerMode", "off");
    currentTarget = getOrElse(argMap, "CurrentTarget", "NA");
    dependencyTrackingMethod = getOrElse(argMap, "DependencyTrackingMethod", "high-level");

    statsfile = getOrError(argMap, "StatsfileOutput", "Missing required arg StatsfileOutput");
    enableDiagnosticsReport = booleanGetOrFalse(argMap, "EnableDiagnosticsReport");
    diagnosticsFile = getOrError(argMap, "DiagnosticsFile", "Missing required arg DiagnosticsFile");
  }

  private static List<Resource> getResources(Map<String, String> args) {
    String[] targets = getCommaList(args, "ResourceTargets");
    String[] sources = getCommaList(args, "ResourceSources");

    if (targets.length != sources.length)
      throw new RuntimeException(
          String.format(
              "mismatch in resources: targets: %s sources: %s",
              getOrEmpty(args, "ResourceTargets"), getOrEmpty(args, "ResourceSources")));

    List<Resource> resources = new ArrayList<Resource>();
    for (int idx = 0; idx < targets.length; idx++) {
      resources.add(new Resource(targets[idx], sources[idx]));
    }
    return resources;
  }

  private static Map<String, String> buildArgMap(List<String> lines) {
    Map<String, String> args = new HashMap<>();
    for (int i = 0; i < lines.size(); i += 2) {
      args.put(lines.get(i).substring(2), lines.get(i + 1));
    }
    return args;
  }

  protected static String[] getTripleColonList(Map<String, String> m, String k) {
    if (m.containsKey(k)) {
      String v = m.get(k);
      if ("".equals(v)) {
        return new String[] {};
      } else {
        return v.split(":::");
      }
    } else {
      return new String[] {};
    }
  }

  private static String[] getCommaList(Map<String, String> m, String k) {
    if (m.containsKey(k)) {
      String v = m.get(k);
      if ("".equals(v)) {
        return new String[] {};
      } else {
        return v.split(",");
      }
    } else {
      return new String[] {};
    }
  }

  private static String getOrEmpty(Map<String, String> m, String k) {
    return getOrElse(m, k, "");
  }

  private static String getOrElse(Map<String, String> attrs, String key, String defaultValue) {
    if (attrs.containsKey(key)) {
      return attrs.get(key);
    } else {
      return defaultValue;
    }
  }

  private static String getOrError(Map<String, String> m, String k, String errorMessage) {
    if (m.containsKey(k)) {
      return m.get(k);
    } else {
      throw new RuntimeException(errorMessage);
    }
  }

  private static boolean booleanGetOrFalse(Map<String, String> m, String k) {
    if (m.containsKey(k)) {
      String v = m.get(k);
      if (v.trim().equals("True") || v.trim().equals("true")) {
        return true;
      }
    }
    return false;
  }

  private static boolean booleanGetOrTrue(Map<String, String> m, String k) {
    if (m.containsKey(k)) {
      String v = m.get(k);
      if (v.trim().equals("False") || v.trim().equals("false")) {
        return false;
      }
    }
    return true;
  }

  public static String[] buildPluginArgs(String packedPlugins) {
    String[] pluginElements = packedPlugins.split(",");
    int numPlugins = 0;
    for (int i = 0; i < pluginElements.length; i++) {
      if (pluginElements[i].length() > 0) {
        numPlugins += 1;
      }
    }

    String[] result = new String[numPlugins];
    int idx = 0;
    for (int i = 0; i < pluginElements.length; i++) {
      if (pluginElements[i].length() > 0) {
        result[idx] = "-Xplugin:" + pluginElements[i];
        idx += 1;
      }
    }
    return result;
  }
}
