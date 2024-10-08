{ pkgs, ... }:
let 
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
    kubectl
  ]);
in {
  environment.systemPackages = with pkgs; [
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

    # JVM / VM
    jdk22_headless
    graalvm-ce
    visualvm

    # Scala
    scalafmt
    unstable.scala-cli
    unstable.sbt
    unstable.coursier
    metals
    jetbrains.idea-ultimate

    websocat

    # Specialization Data
    dbeaver-bin
    sqldeveloper
    file

    oracle-instantclient
    mariadb
    postgresql

    #Gimp 
    gimp
    freecad
  ];
}
