{ pkgs, ... }:
{
  home.file.".local/bin/nvim-gui" = {
    text = '' 
    exec ${pkgs.neovide}/bin/neovide --multigrid -- -u "$LUNARVIM_BASE_DIR/init.lua" "$@"
    '';
    executable = true;
  };

  home.file.".config/lvim/config.lua" = {
    source = lvim/config.lua;
  };

  home.file.".config/lvim/lua" = {
    source = lvim/lua;
  };
}
