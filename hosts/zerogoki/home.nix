{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "prnsh";
  home.homeDirectory = "/home/prnsh";

  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # applications
    discord
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    claude-code
    code-cursor
    codex
    spotify
    spicetify-cli
    wezterm
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
    ".config/wezterm" = { source = dotfiles/wezterm; recursive = true; };
    ".icons" = { source = dotfiles/cursors; recursive = true; };
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately. ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/prnsh/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    XCURSOR_THEME = "BreezeX-Light";
    XCURSOR_SIZE = "24";
  };

  home.pointerCursor = {
    name = "Breeze";
    package = pkgs.breeze-gtk;
    size = 24;
    gtk.enable = true;
  };

  programs.polybar = {
    enable = true;
    script = "${pkgs.polybar}/bin/polybar main";
  };
  xdg.configFile."polybar".source = ../../../polybar;


  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Set wallpaper";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${./wallpapers/dreams.jpg}";
      Type = "oneshot";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
