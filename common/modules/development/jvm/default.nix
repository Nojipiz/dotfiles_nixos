{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # JVM / VM
    jdk17_headless
    visualvm

    # Scala
    scalafmt
    scala-cli
    sbt
    coursier
  ];
}
