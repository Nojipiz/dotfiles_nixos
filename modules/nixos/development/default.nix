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
    unstable.zed-editor
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

    # Specialization Data
    dbeaver-bin
    oracle-instantclient
    mariadb

    #Gimp 
    gimp
    freecad
  ];
}
