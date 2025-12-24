{
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
      v = "nvim";
    };
  };
}
