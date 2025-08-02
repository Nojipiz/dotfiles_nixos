{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    # JVM / VM
    jdk17_headless
    visualvm

    # Scala
    scalafmt
    scala-cli
    sbt
    coursier
    metals
  ];
}
