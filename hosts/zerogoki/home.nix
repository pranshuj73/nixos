{ config, pkgs, inputs, ... }:

let
  dotfiles = "/home/prnsh/dotfiles";
  oos = config.lib.file.mkOutOfStoreSymlink;

  android = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "36" ];
    buildToolsVersions = [ "36.0.0" ];
    platformToolsVersion = "36.0.2";
    includeNDK = true;
    includeEmulator = false;
  };
in
{
  home.username = "prnsh";
  home.homeDirectory = "/home/prnsh";
  home.stateVersion = "25.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    inputs.handy.homeManagerModules.default
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
    wezterm
    readest

    # programming utilities
    claude-code
    code-cursor
    codex

    # android development
    android.androidsdk
    android-tools
    jdk17
    scrcpy

    # utilities
    maim
  ];

  nixpkgs.config.android_sdk.accept_license = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    XCURSOR_THEME = "BreezeX-Light";
    XCURSOR_SIZE = "24";

    ANDROID_HOME = "${android.androidsdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${android.androidsdk}/libexec/android-sdk";
    ANDROID_NDK_HOME = "${android.androidsdk}/libexec/android-sdk/ndk-bundle";
    ANDROID_NDK_ROOT = "${android.androidsdk}/libexec/android-sdk/ndk-bundle";
    JAVA_HOME = "${pkgs.jdk17}";
  };

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.bun/bin"
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #
  # Program Specific Configuration
  #
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


  services.handy.enable = true;
  options.services.handy = {
    enable = lib.mkEnableOption "Handy speech-to-text user service";

    package = lib.mkOption {
      type = lib.types.package;
      defaultText = lib.literalExpression "handy.packages.\${system}.handy";
      description = "The Handy package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.handy = {
      Unit = {
        Description = "Handy speech-to-text";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/handy";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
      ];
    };

    initContent = ''
      # Prevent zsh-autosuggestions from hooking any keys
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()

      # Accept entire suggestion with Tab
      bindkey '^I' autosuggest-accept
      bindkey '^[[Z' autosuggest-accept

      # Ctrl + Backspace
      bindkey '^H' backward-kill-word
    '';

    shellAliases = {
      df = "cd ~/dotfiles && nvim";
      nixos = "cd ~/nixos && nvim";
      renix0 = "sudo nixos-rebuild switch --flake /etc/nixos#zerogoki";
      clnix0 = "sudo nix-collect-garbage --delete-older-than 3d";
      sl = "cd ~";
      gtree = "git ls-tree -r --name-only HEAD | tree --fromfile";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
