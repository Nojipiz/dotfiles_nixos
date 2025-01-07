{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    starship
  ];
  programs.nix-index.enableFishIntegration = true; 
  programs.starship = { 
    enable = true;
    settings = { 
      gcloud = {
        format = "[$symbol]($style)";
        symbol = "☁️ ";
        style = "bold blue";
      };

      java = {
        detect_extensions = ["java" "cljs" "cljc"];
      };

      scala = {
        format = "[$\{symbol} ($\{version} )]($style)";
        symbol = "Scala";
        style = "bold red dimmed";
      };
    };
  };

}
