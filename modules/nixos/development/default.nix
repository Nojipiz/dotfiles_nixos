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
    gradle

    # Infrastructure
    docker
    docker-compose
    packer
    qemu
    unstable.opentofu 
    gdk
    openssl

    # Javascript
    nodejs

    # VM
    jdk17_headless
    graalvm-ce

    # Scala
    scalafmt
    unstable.sbt
    unstable.coursier
    unstable.metals

    # Elm
    elmPackages.elm

    # DB
    postgresql 
    mariadb
    confluent-platform 

    # GCC
    gcc
  ];
}
