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
    graalvm-ce

    # Scala
    scalafmt
    unstable.scala-cli
    unstable.sbt
    unstable.coursier
    unstable.metals

    # Specialization Data
    dbeaver-bin
    mariadb
  ];
}
