{
  inputs,
  python3,
  lib,
  config,
  pkgs,
  ...
}: {
  disabledModules = [ "services/monitoring/grafana.nix" ];

  imports = [
    ./hardware-configuration.nix
    ./services/frigate.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "thinkcentre";
  
  # Enable networking
  networking.networkmanager.enable = true;

    nixpkgs = {
    overlays = [   
       (final: prev: {
         myfrigate = final.frigate.overrideAttrs (oldAttrs: {
           postPatch = ''                
                substituteInPlace frigate/const.py \
                   --replace "/tmp/cache" "/tmp/frigate/cache"
                substituteInPlace frigate/record.py \
                   --replace "/tmp/cache" "/tmp/frigate/cache"
                substituteInPlace frigate/http.py \
                   --replace "/tmp/cache/" "/tmp/frigate/cache"
          '' + (oldAttrs.postPatch or "");
         });
       })
    ];
    
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };
  
  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  boot.initrd.kernelModules = ["i915"];
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [
    pkgs.intel-media-driver
    pkgs.vaapiIntel
    pkgs.vaapiVdpau
    pkgs.libvdpau-va-gl
  ];
  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx.enable = true;
  services.frigate = {
    package = pkgs.myfrigate;
    enable = true;
    hostname = "nvr.klovanych.org";
    settings = {
      cameras = {
        backyard-view-cam = {
          ffmpeg = {
            hwaccel_args = "preset-vaapi";
            inputs = [
              {
                path = "rtsp://admin:GwAHjK60CwjhZ5BmOQx@192.168.88.37:554/stream1";
                roles = ["record"];
              }
              {
                path = "rtsp://admin:GwAHjK60CwjhZ5BmOQx@192.168.88.37:554/stream2";
                roles = ["detect"];
              }
            ];
          };
          detect = {
            enabled = true;
            width = 1920;
            height = 1080;
            fps = 8;
          };
          snapshots = {
            enabled = true;
            bounding_box = true;
          };
          record = {
            enabled = true;
          };
        };
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

  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nazar = {
    isNormalUser = true;
    description = "nazar";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAhZ6wg+6tHLPXOiMnvDsf7jd/N6RbzEaJaJa0ElL3F n.klovanych@atwix.com"
    ];
    packages = with pkgs; [
      git
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAhZ6wg+6tHLPXOiMnvDsf7jd/N6RbzEaJaJa0ElL3F n.klovanych@atwix.com"
  ];

  
  # Open ports in the firewall.
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
