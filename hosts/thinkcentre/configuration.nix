{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  disabledModules = [ "services/video/frigate.nix" ];

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
        frigate = prev.frigate.overrideAttrs (oldAttrs: {
          postPatch = ''
               substituteInPlace frigate/http.py \
                   --replace "/tmp/cache/" "/var/cache/frigate/"
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
  networking.firewall.allowedTCPPorts = [80 443 8123 1883 1984 8555];
  services.nginx.enable = true;

  services.esphome = {
    enable = true;
    address = "0.0.0.0";
  };

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
  ];

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "met"
      "ffmpeg"
      "radio_browser"
      "mqtt"
      "wled"
    ];
    customComponents = [
      (pkgs.python311Packages.callPackage ./packages/home-assistant/custom_components/frigate-hass-integration.nix {})
    ];
    config = {
      default_config = {};
      "automation ui" = "!include /var/lib/hass/automations.yaml";
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.go2rtc = {
    enable = true;
    settings.webrtc.candidates = "192.168.88.12:8555";
    settings.streams = {
      frontgate-right-camera-view = [
        "rtsp://admin:UDF23If3weoEsA23GHndsdEW8x@192.168.88.64:554/stream1"
        "ffmpeg:frontgate-right-camera-view#audio=aac"
      ];
      frontgate-left-camera-view = [
        "rtsp://admin:3r5465XNlika31$@192.168.88.18:554/stream1"
        "ffmpeg:frontgate-left-camera-view#audio=aac"
      ];
      driveway-camera-view = [
        "rtsp://admin:GwAHjK60CwjhZ5BmOQx@192.168.88.37:554/stream1"
        "ffmpeg:driveway-camera-view#audio=aac"
      ];
      backyard-camera-view = [
        "rtsp://admin:aiEw3GfV5l23dN4lP@192.168.88.66:554/stream1"
        "ffmpeg:backyard-camera-view#audio=aac"
      ];
      backyard-enterance-camera-view = [
        "rtsp://admin:Xz4cgRXmWmqrXih3Xnny@192.168.88.29:554/stream1"
        "ffmpeg:backyard-enterance-camera-view#audio=aac"
      ];
      neighborhood-side-camera-view = [
        "rtsp://admin:Dj3CUvD34gjU2lLB6H0PlDF@192.168.88.65:554/stream1"
        "ffmpeg:neighborhood-side-camera-view#audio=aac"
      ];
    };
  };

  services.frigate = {
    enable = true;
    hostname = "nvr.klovanych.org";
    settings = {
      birdseye = {
        enabled = true;
        mode = "continuous";
        width = "1920";
        height = "1080";
      };
      objects.track =
        [
          "person"
          "car"
          "cat"
          "dog"
        ];
      detect = {
        enabled = true;
        width = 640;
        height = 480;
        fps = 20;
      };
      snapshots = {
        enabled = true;
        bounding_box = true;
      };
      mqtt = {
        enabled = true;
        host = "localhost";
        port = "1883";
      };
      ffmpeg = {
        output_args.record = "-f segment -segment_time 10 -segment_format mp4 -reset_timestamps 1 -strftime 1 -c:v copy -c:a aac";
        hwaccel_args = "preset-vaapi";
      };
      go2rtc = {
        streams = {
      frontgate-right-camera-view = [
        "rtsp://admin:UDF23If3weoEsA23GHndsdEW8x@192.168.88.64:554/stream1"
        "ffmpeg:frontgate-right-camera-view#audio=aac"
      ];
      frontgate-left-camera-view = [
        "rtsp://admin:3r5465XNlika31%@192.168.88.18:554/stream1"
        "ffmpeg:frontgate-left-camera-view#audio=aac"
      ];
      driveway-camera-view = [
        "rtsp://admin:GwAHjK60CwjhZ5BmOQx@192.168.88.37:554/stream1"
        "ffmpeg:driveway-camera-view#audio=aac"
      ];
      backyard-enterance-camera-view = [
        "rtsp://admin:Xz4cgRXmWmqrXih3Xnny@192.168.88.29:554/stream1"
        "ffmpeg:backyard-camera-view#audio=aac"
      ];
      backyard-camera-view = [
        "rtsp://admin:aiEw3GfV5l23dN4lP@192.168.88.66:554/stream1"
        "ffmpeg:backyard-camera-view#audio=aac"
      ];
      neighborhood-side-camera-view = [
        "rtsp://admin:Dj3CUvD34gjU2lLB6H0PlDF@192.168.88.65:554/stream1"
        "ffmpeg:neighborhood-side-camera-view#audio=aac"
      ];
        };
      };
      cameras = {
        driveway-camera-view = {
          ffmpeg = {
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
          record.enabled = true;
        };
        frontgate-right-camera-view = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://admin:UDF23If3weoEsA23GHndsdEW8x@192.168.88.64:554/stream1";
                roles = ["record"];
              }
              {
                path = "rtsp://admin:UDF23If3weoEsA23GHndsdEW8x@192.168.88.64:554/stream2";
                roles = ["detect"];
              }
            ];
          };
          record.enabled = true;
        };
        frontgate-left-camera-view = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://admin:3r5465XNlika31$@192.168.88.18:554/stream1";
                roles = ["record"];
              }
              {
                path = "rtsp://admin:3r5465XNlika31$@192.168.88.18:554/stream2";
                roles = ["detect"];
              }
            ];
          };
          record.enabled = true;
        };
        neighborhood-side-camera-view = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://admin:Dj3CUvD34gjU2lLB6H0PlDF@192.168.88.65:554/stream1";
                roles = ["record"];
              }
              {
                path = "rtsp://admin:Dj3CUvD34gjU2lLB6H0PlDF@192.168.88.65:554/stream2";
                roles = ["detect"];
              }
            ];
          };
          record.enabled = true;
        };
        backyard-camera-view = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://admin:aiEw3GfV5l23dN4lP@192.168.88.66:554/stream1";
                roles = ["record"];
              }
              {
                path = "rtsp://admin:aiEw3GfV5l23dN4lP@192.168.88.66:554/stream2";
                roles = ["detect"];
              }
            ];
          };
          record.enabled = true;
        };
        backyard-enterance-camera-view = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://admin:Xz4cgRXmWmqrXih3Xnny@192.168.88.29:554/stream1";
                roles = ["record"];
              }
              {
                path = "rtsp://admin:Xz4cgRXmWmqrXih3Xnny@192.168.88.29:554/stream2";
                roles = ["detect"];
              }
            ];
          };
          record.enabled = true;
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFJ25+ECs9FIYy/QeNQ26l4dQv6JyQ/HIetjtLjowP4 nazar@t440p"
    ];
    packages = with pkgs; [
      git
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFJ25+ECs9FIYy/QeNQ26l4dQv6JyQ/HIetjtLjowP4 nazar@t440p"
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
