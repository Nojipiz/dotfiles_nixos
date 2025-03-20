{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Scala
    metals

    # Elixir
    elixir-ls
    elixir_1_18

    # Go
    gopls
    go
  ];
}
