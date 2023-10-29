{ config, lib, pkgs, ... }:

let
  env = {
    LUNARVIM_RUNTIME_DIR = "${config.home.homeDirectory}/.local/share/lvim";
    LUNARVIM_CONFIG_DIR = "${config.home.homeDirectory}/.config/lvim";
    LUNARVIM_CACHE_DIR = "${config.home.homeDirectory}/.cache/lvim";
    LUNARVIM_BASE_DIR = "${lunarvimDrv}/lvim";
  };

  extraPackages = with pkgs; [
    git
    rnix-lsp
    tree-sitter
    sumneko-lua-language-server
  ];

  nvim = config.programs.neovim.finalPackage;

  lunarvimDrv = pkgs.stdenv.mkDerivation
    {
      pname = "lunarvim";
      version = "1.3.0";

      src = pkgs.fetchFromGitHub {
        owner = "LunarVim";
        repo = "LunarVim";
        rev = "release-1.3/neovim-0.9";
        sha256 = "sha256-Zh5RnQmQ7k13bpTjcfD7kpnL9TbEfYeWZsY0LQD/UCs=";
      };

      nativeBuildInputs = [ pkgs.makeWrapper pkgs.coreutils pkgs.gnused ];
      buildInputs = [ nvim ];

      buildPhase = ''
        echo Skipping Build Phase
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp -r $(pwd) $out/lvim

        export shim="$out/lvim/utils/bin/lvim.template"

        substituteInPlace "$shim" \
          --replace "exec -a lvim nvim" "exec -a lvim ${nvim}/bin/nvim" \
          --replace "RUNTIME_DIR_VAR" "\"${env.LUNARVIM_RUNTIME_DIR}\"" \
          --replace "CONFIG_DIR_VAR" "\"${env.LUNARVIM_CONFIG_DIR}\"" \
          --replace "CACHE_DIR_VAR" "\"${env.LUNARVIM_CACHE_DIR}\"" \
          --replace "BASE_DIR_VAR" "\"$out/lvim\""

        chmod +x "$shim"

        makeWrapper "$shim" "$out/bin/lvim" \
          --set LUNARVIM_RUNTIME_DIR "${env.LUNARVIM_RUNTIME_DIR}" \
          --set LUNARVIM_CONFIG_DIR "${env.LUNARVIM_CONFIG_DIR}" \
          --set LUNARVIM_CACHE_DIR "${env.LUNARVIM_CACHE_DIR}" \
          --set LUNARVIM_BASE_DIR "$out/lvim" \
          --prefix PATH : ${lib.makeBinPath (extraPackages ++ [ nvim ])}

        runHook postInstall
      '';
    };
in
{
  home.packages = [
    pkgs.nodePackages.neovim
    pkgs.sumneko-lua-language-server
    pkgs.nodePackages_latest.typescript-language-server
    pkgs.nil
    pkgs.xclip
    pkgs.terraform-ls
    lunarvimDrv
  ];

  home.sessionVariables = env;

  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];

    inherit extraPackages;
  };

  home.file.".config/lvim/config.lua" = {
    source = lvim/config.lua;
  };

  home.file.".config/lvim/lua" = {
    source = lvim/lua;
  };
}
