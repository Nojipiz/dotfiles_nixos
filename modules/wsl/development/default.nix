{ pkgs, ... }:
{

  # Excludes all the flakes, my company don't uses Nix
  home.file = { 
    ".git/info/exclude" = {
      text = "flake.nix";
    };
  };

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
