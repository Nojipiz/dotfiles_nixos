{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ghc
    haskellPackages.cabal-install
    haskellPackages.haskell-language-server
    zlib
  ];
}
