# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zerogoki"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; nix = { # Hard link identical files in the store automatically
    settings.auto-optimise-store = true;
    # automatically trigger garbage collection
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 15d";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable bspwm
  services.xserver.windowManager.bspwm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:swapescape";
  };
  services.libinput = {
    enable = true;

    touchpad = {
      naturalScrolling = true;
      tapping = true;            # tap to click
      middleEmulation = true;    # 3-finger middle click
      disableWhileTyping = false;
    };

    mouse = {
      naturalScrolling = false;
    };
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.prnsh = {
    isNormalUser = true;
    description = "prnsh";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "prnsh" = import ./home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # de / wm / comp
    bspwm
    sxhkd
    polybar
    picom
    rofi
    clipmenu
    xclip

    # editors
    neovim
    vim

    # utilities
    wget
    unzip
    zoxide
    gh
    git
    lazygit
    ripgrep
    mpv
    brightnessctl
    playerctl
    feh
    killall
    tree-sitter

    # terminal
    zsh
    oh-my-zsh
    zsh-autosuggestions

    # lang support
    python3
    zig
    go
    nodejs
    pnpm
    bun
    gcc
    cargo
    rustc
    lua
    lua-language-server
  ];

  # Install firefox.
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # env vars
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;

    settings = {
      # Shadows
      shadow = true;
      shadow-radius = 10;
      shadow-opacity = 0.8;
      shadow-offset-x = -7;
      shadow-offset-y = -7;

      # Fading / animations
      fading = true;
      fade-in-step = 0.1;
      fade-out-step = 0.1;
      fade-delta = 5;
      no-fading-openclose = false;

      # Rounded corners
      corner-radius = 12;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      # Opacity
      inactive-opacity = 0.6;

      # Blur (modern syntax)
      blur = {
        method = "dual_kawase";
        strength = 7;
      };

      blur-background = true;
      blur-background-frame = true;
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "window_type = 'dropdown_menu'"
        "window_type = 'popup_menu'"
        "class_g = 'maim'"
        "class_g = 'slop'"
      ];

      # Optional: detect rounded corners correctly
      detect-rounded-corners = true;
      detect-client-opacity = true;

      # Completely disable compositor effects for certain window types
      wintypes = {
        dock = {
          shadow = false;
          fade = false;
          blur-background = false;
        };

        dropdown_menu = {
          shadow = false;
          fade = false;
          blur-background = false;
        };

        popup_menu = {
          shadow = false;
          fade = false;
          blur-background = false;
          opacity = 1.0;
        };

        tooltip = {
          shadow = false;
          fade = false;
          blur-background = false;
          opacity = 1.0;
        };

        utility = {
          shadow = false;
          fade = false;
          blur-background = false;
          opacity = 1.0;
        };
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8081 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
