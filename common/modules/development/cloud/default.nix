{ pkgs, ... }:
let 
  googleCloud = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
    kubectl
  ]);
in {
  environment.systemPackages = with pkgs; [
    unstable.opentofu 
    googleCloud
  ];
}
