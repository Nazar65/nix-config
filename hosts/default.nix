{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
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

  environment.shells = with pkgs; [zsh];
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [
    pkgs.intel-media-driver
    pkgs.vaapiIntel
    pkgs.vaapiVdpau
    pkgs.libvdpau-va-gl
  ];

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [51820];
    checkReversePath = false; #wireguard
  };
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    127.0.0.1 burpee.local
    127.0.0.1 reinders.local
  '';
  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "uk_UA.UTF-8/UTF-8"
  ];

  xdg.portal.config = {
    enable = true;
    extraPortals = [
      # To make slack screen-sharing possible
      pkgs.xdg-desktop-portal-wlr
      # gtk portal needed to make gtk apps happy
      pkgs.xdg-desktop-portal-gtk
    ];
    #xdgOpenUsePortal = true;
    wlr.enable = true;
  };

  programs.ssh = {
    startAgent = true;
  };
  fileSystems."/mnt/media" = {
    device = "//192.168.88.20/thegoat";
    fsType = "cifs";
    options = ["username=spyware" "password=3r5465XNlika31" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s"];
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.dconf.enable = true;
  security.pam.services.swaylock = {};
  security.polkit.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
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
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFJ25+ECs9FIYy/QeNQ26l4dQv6JyQ/HIetjtLjowP4 nazar@t440p"
      ];
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        cifs-utils
      ];
    };
  };
}
