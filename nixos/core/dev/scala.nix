{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    scalafmt
    unstable.sbt
    unstable.coursier
    unstable.metals
    postgresql # TODO: Remove from here 
    confluent-platform # TODO: Remove from here 
  ];
}
