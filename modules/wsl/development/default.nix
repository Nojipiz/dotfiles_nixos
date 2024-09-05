{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lunarvim
    unstable.zed-editor
    gradle

    # Infrastructure
    docker
    docker-compose
    openssl

    # Javascript
    nodejs

    # VM
    jdk11_headless

    # Scala
    scalafmt
    unstable.scala-cli
    unstable.sbt
    unstable.coursier
    metals

    # Database 
    # oracle-instantclient
  ];
}
