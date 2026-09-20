{
  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting '''
    '';
    interactiveShellInit = ''
      fish_add_path ~/.bun/bin
      fish_add_path ~/.local/bin
    '';
    shellAliases = {
      g = "lazygit";
      v = "nvim";
    };
  };
}
