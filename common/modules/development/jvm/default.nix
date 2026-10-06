{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # jetbrains.idea
    # JVM / VM
    jdk25
    jdk11 # Not headless because some Play code requires
    visualvm

    # Scala
    scalafmt
    (unstable.scala-cli.override { jre = jdk25; })
    sbt
    unstable.mill
    coursier
    unstable.metals

    # Native linking (Scala Native needs clang in PATH)
    clang
  ];
}
