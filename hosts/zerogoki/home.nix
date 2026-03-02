{ config, pkgs, inputs, ... }:

let
  dotfiles = "/home/prnsh/dotfiles";
  oos = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.username = "prnsh";
  home.homeDirectory = "/home/prnsh";
  home.stateVersion = "25.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # dotfile mgmt
  home.file = {
    ".config/nvim" = { source = oos "${dotfiles}/nvim"; recursive = true; };
    ".config/wezterm" = { source = oos "${dotfiles}/wezterm"; recursive = true; };
    ".config/polybar" = { source = oos "${dotfiles}/polybar"; recursive = true; };
    ".icons" = { source = oos "${dotfiles}/cursors"; recursive = true; };
  };


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # applications
    discord
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    claude-code
    code-cursor
    codex
    wezterm
  ];

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
    ];
    enabledCustomApps = with spicePkgs.apps; [
      newReleases
    ];
    enabledSnippets = with spicePkgs.snippets; [];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    XCURSOR_THEME = "BreezeX-Light";
    XCURSOR_SIZE = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
