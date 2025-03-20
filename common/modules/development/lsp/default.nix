{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Scala
    metals

    # Elixir
    elixir-ls

    # Go
    gopls
  ];
}
