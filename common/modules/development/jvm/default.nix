{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jetbrains.idea
    # JVM / VM
    jdk17
    jdk11 # Not headless because some Play code requires
    visualvm

    # Scala
    scalafmt
    scala-cli
    sbt
    unstable.mill
    coursier
    metals
  ];
}
