{ pkgs, ... }:
let 
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
    kubectl
  ]);
in {
  home.packages = with pkgs; [
    # Android
    unstable.android-studio 
    gradle

    # Infrastructure
    docker
    docker-compose
    unstable.opentofu 
    gdk
    # Javascript
    nodejs
    # JVM
    jdk17_headless
    graalvm17-ce

    # Scala
    scalafmt
    unstable.sbt
    unstable.coursier
    unstable.metals

    # DB
    postgresql 
    confluent-platform 
  ];
}
