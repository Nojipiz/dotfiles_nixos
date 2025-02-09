{pkgs, ...}:
{  
  environment.systemPackages = with pkgs; [
    chromium
    firefox
    tor-browser
    pcmanfm
  ];
  programs.chromium.enable = true;
  programs.chromium.extraOpts = {
    BookmarkBarEnabled = true;
    BrowserSignin = 0;
    DefaultBrowserSettingEnabled = false;
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderSearchURL = "https://google.com/search?q={searchTerms}";
    ExtensionInstallForcelist = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden: Pasword Manger
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # UBlock
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # DarkReader
    ];
    HighContrastEnabled = true;
    ImportBookmarks = false;
    ManagedBookmarks = [
# {toplevel_name = "Links";}
# {
#   name = "Comunications";
#   children = [
#     {
#       name = "discord";
#       url = "https://discord.com";
#     }
#     {
#       name = "matrix";
#       url = "https://app.element.io";
#     }
#   ];
# }
# {
#   name = "Nix";
#   children = [
#     {
#       name = "nixos-forum";
#       url = "https://discourse.nixos.org/latest";
#     }
#   ];
# }
# {
#   name = "Rust";
#   children = [
#     {
#       name = "forum";
#       url = "https://users.rust-lang.org";
#     }
#   ];
# }
      ];
    PasswordManagerEnabled = false;
    ShowAppsShortcutInBookmarkBar = false;
    SyncDisabled = true;
  };
}
