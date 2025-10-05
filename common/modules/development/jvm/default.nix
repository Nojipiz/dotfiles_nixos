{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    # JVM / VM
    jdk17_headless
    jdk11 # Not headless because some Play code requires
    visualvm

    # Scala
    scalafmt
    scala-cli
    sbt
    mill
    coursier
    metals
  ];
}
