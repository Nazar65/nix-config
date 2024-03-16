{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    ./hardware-configuration.nix
  ];

# Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  services.xserver.excludePackages = [ pkgs.xterm ];
  environment.shells = with pkgs; [ zsh ];
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-text-editor
    gnome-usage
    gnome-connections
    gnome-secrets
    simple-scan
    yelp
  ]) ++ (with pkgs.gnome; [
    rygel
    gnome-calculator
    gnome-logs
    gnome-disk-utility
    gnome-weather
    gnome-contacts
    gnome-clocks
    gnome-maps
    gnome-contacts
    nautilus
    cheese # webcam tool
    gnome-music
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    baobab # disk usage analyzer
    file-roller
    gnome-calendar
    simple-scan
    gnome-font-viewer
    yelp
    eog
    gnome-color-manager
  ]);

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  # better performance than the actual Intel driver
  services.xserver.videoDrivers = ["modesetting"];
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [
    pkgs.intel-media-driver
    pkgs.vaapiIntel
    pkgs.vaapiVdpau
    pkgs.libvdpau-va-gl
  ];
  security.rtkit.enable = true;
  networking.hostName = "t440p";
  networking.networkmanager.enable = true;
  networking.extraHosts =
    ''
    127.0.0.1 burpee.local
  '';
  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "uk_UA.UTF-8/UTF-8"
  ];
  

services.strongswan = {
    enable = true;
    secrets = [
      "ipsec.d/ipsec.nm-l2tp.secrets"
    ];
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us,ua";
    xkbVariant = "";
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  programs.zsh.enable = true;
  
  users.users = {
    nazar = {
      shell = pkgs.zsh;
      isNormalUser = true;     
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        home-manager
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
