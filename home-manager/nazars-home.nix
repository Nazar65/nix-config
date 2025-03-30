{ inputs
, lib
, config
, pkgs
, ...
}:
let
  inherit (lib.hm.gvariant) mkTuple;
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

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

    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "nazar";
    homeDirectory = "/home/nazar";
    packages = with pkgs; [
      slack
      nodejs
      qutebrowser
      foot
      nixpkgs-fmt
    ];
  };

  services.swayidle = let
  lockcmd = "${pkgs.swaylock}/bin/swaylock -fF"; in
  {
    enable = true;
    events = [
      { event = "before-sleep"; command = lockcmd; }
      { event = "lock"; command = lockcmd; }
    ];
    timeouts = [
      # Turn off screen (just before locking)
      {
        timeout = 170;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
      # Lock computer
      {
        timeout = 180;
        command = lockcmd;
      }
    ];
  };
 programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };
 home.sessionVariables = {
    GDK_BACKEND = "wayland"; # GTK
    XDG_SESSION_TYPE = "wayland"; # Electron
    QT_QPA_PLATFORM = "wayland"; # QT
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
 };
   dconf.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
    '';
    checkConfig = false;
    config = let
      modifier = "Mod4";
    in rec {
       output = {
        "*" = {
          background = "~/Pictures/firewatch-galaxy.jpg fill";
        };
        DP-1 = {
          pos = "2560 0";
          res = "2560x1440@144Hz";
          scale = "1";
        };
       };
      input = {
        "type:keyboard" = {
          "xkb_layout"  = "us,ua";
          "xkb_options" = "ctrl:nocaps,grp:alt_shift_toggle";
        };
      };
      keybindings = {
          "${modifier}+Shift+r" = "reload";
          "${modifier}+f" = "exec ${pkgs.qutebrowser}/bin/qutebrowser";
          "${modifier}+t" = "exec ${pkgs.foot}/bin/foot";
          "${modifier}+a" = "exec ${pkgs.fuzzel}/bin/fuzzel";
      };
    };
  };
  
  # Add stuff for your user as you see fit:
  programs.home-manager.enable = true;
   gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
  xdg.enable = true;
  accounts.email.accounts = {
    personal = {
      primary = true;
      address = "nazarn96@gmail.com";
      realName = "Nazar Klovanych";
      userName = "klovanych";
    };
  };

  programs.fish.enable = true;
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    };
  };

  programs.firefox = {
    enable = true;
  };
  programs.git = {
    enable = true;
    userName = "klovanych";
    userEmail = "nazarn96@gmail.com";
    extraConfig = {
      color.ui = true;
      credential.helper = "store --file ~/.git-credentials";
    };
    signing = {
      key = "B510AA5B74EAF294";
      signByDefault = true;
    };
  };

  services.gpg-agent.pinentryPackage = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  programs.fuzzel = {
     enable = true;
     settings = {
      main = {
        prompt="❯ ";
        icon-theme="Papirus-Dark";
        font="JetBrains Mono:weight=bold:size=14";
        dpi-aware="no";
        width=50;
        horizontal-pad=8;
        vertical-pad=8;
        filter-desktop="yes";
        list-executables-in-path="no";
        show-actions="no";
        lines=12;
        exit-on-keyboard-focus-loss="yes";
      };

      colors = {
        background="1d1f21dd";
        border="5e81accc";
        text="a6accdff";
        match="c792eacc";
        selection="a6accdff";
        selection-text="232635ff";
      };

      border = {
        radius=25;
      };
    };
  };

  programs.direnv.enable = true;
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "DP-1"
        ];
        modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" ];
        "clock" = {
          "format" = "{:%Y-%m-%d %H:%M %a W%V}";
          "format-alt" = "{:%a, %d. %b  %H:%M}";
        };
        "tray" = {
          "icon-size" = 21;
          "spacing" = 10;
        };
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
        };
      };
    };
  };
  services.gnome-keyring.enable = true;
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "robbyrussell";
    };
    shellAliases = {
      ll = "ls -l";
      home-flake-switch = "home-manager switch --flake $*";
      system-rebuild-switch = "sudo nixos-rebuild switch --flake $*";
      magento-cloud = "/home/nazar/.magento-cloud/bin/magento-cloud $*";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
