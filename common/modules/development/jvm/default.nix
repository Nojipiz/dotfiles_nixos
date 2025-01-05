{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # JVM / VM
    jdk17_headless
    visualvm

    # Scala
    scalafmt
    unstable.scala-cli
    unstable.sbt
    unstable.coursier
    metals
  ];
}
