{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    starship
    openssl
  ];

  # programs.nix-index.enableFishIntegration = true;
  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting '''
    '';
    interactiveShellInit = ''
      fish_add_path ~/mutable_node_modules/bin
      fish_add_path ~/.local/bin
    '';
    shellAliases = {
      g = "lazygit";
      v ="lvim";
    };
  };

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
