{ pkgs, ... }:
let 
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
    kubectl
  ]);
in {
  environment.systemPackages = with pkgs; [
    # Android
    unstable.android-studio 
    lunarvim
    gradle

    # Infrastructure
    docker
    docker-compose
    packer
    unstable.opentofu 
    qemu
    gdk
    openssl

    # Javascript
    nodejs

    # VM
    jdk17_headless
    graalvm-ce

    # Scala
    scalafmt
    unstable.scala-cli
    unstable.sbt
    unstable.coursier
    unstable.metals
    websocat

    # Elm
    elmPackages.elm
    elmPackages.elm-language-server

    # Specialization Data
    dbeaver
    oracle-instantclient
    mariadb

    #Gimp 
    gimp
    freecad
  ];
}
