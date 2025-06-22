{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    haskell.compiler.ghc983
    haskellPackages.cabal-install 
    haskellPackages.haskell-language-server
    zlib
  ];
}
