{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.hm.gvariant) mkTuple;
in {
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
      gcc
      nodejs
      nix-direnv
      pulseaudio
      browserpass
      pavucontrol
      pinentry
      devenv
      libnotify
      foot
      gnupg
      stylua
      wofi
      dmenu
      neovide
      python311Packages.tldextract
      fira-code
      fira-code-symbols
      font-awesome
      nerdfonts
      cargo
      fzf
      ripgrep
      luarocks
      cmake
      unzip
      noto-fonts
      noto-fonts-emoji
      wl-clipboard
      proggyfonts
      (nerdfonts.override {
        fonts = [
          "CascadiaCode"
          "CodeNewRoman"
          "FantasqueSansMono"
          "Iosevka"
          "ShareTechMono"
          "Hermit"
          "JetBrainsMono"
          "FiraCode"
          "FiraMono"
          "Hack"
          "Hasklig"
          "Ubuntu"
          "UbuntuMono"
        ];
      })
    ];
  };

  xdg.configFile = {
    "nvim/lua".source = ../dotfiles/nvim/lua;
    "nvim/init.lua".source = ../dotfiles/nvim/init.lua;
  };
  programs.browserpass = {
    enable = true;
    browsers = ["firefox"];
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      #LSP
      lua-language-server
      gopls

      #Formater
      stylua
      nixpkgs-fmt
    ];
  };
  services.swayidle = let
    lockcmd = "${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --clock --effect-blur 9x7 --effect-vignette 0.25:0.5";
  in {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = lockcmd;
      }
      {
        event = "lock";
        command = lockcmd;
      }
    ];
    timeouts = [
      {
        timeout = 170;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
      {
        timeout = 150;
        command = lockcmd;
      }
    ];
  };
  home.sessionVariables = {
    GDK_BACKEND = "wayland"; # GTK
    XDG_SESSION_TYPE = "wayland"; # Electron
    QT_QPA_PLATFORM = "wayland"; # QT
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
    MOZ_ENABLE_WAYLAND = 1;
    GTK_USE_PORTAL = 1;
  };

  services.mako = {
    enable = true;
    backgroundColor = "#1c1f26ee";
    borderColor = "#89AAEBee";
    borderRadius = 6;
    borderSize = 2;
    padding = "25";
    width = 500;
    height = 500;
    margin = "25";
    icons = true;
    anchor = "top-right";
    defaultTimeout = 5000;
    font = "Iosevka 12";
    maxVisible = 5;
    layer = "overlay";
    textColor = "#ffffff";
  };

  programs.waybar = {
    enable = true;
    settings = {
      primary = {
        mode = "dock";
        height = 24;
        margin = "8 8 0 8";
        spacing = 0;
        modules-left = ["custom/menu" "sway/workspaces" "sway/mode"];
        modules-center = ["clock"];
        modules-right = [
          "tray"
          "pulseaudio"
          "custom/vpn"
          "cpu"
          "memory"
          "temperature"
        ];

        "clock" = {
          "format" = "<span> </span>{:%A %b %d %H:%M}";
          "calendar" = {
            "mode" = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "on-click-right" = "mode";
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "days" = "<span color='#ff9aef'><b>{}</b></span>";
              "weeks" = "<span color='#85dff8'><b>W{}</b></span>";
              "weekdays" = "<span color='#f2e1d1'><b>{}</b></span>";
              "today" = "<span color='#ff8994'><b><u>{}</u></b></span>";
            };
          };
          "tooltip-format" = "<tt>{calendar}</tt>";
        };
        "custom/vpn" = {
          format = " VPN: {}";
          exec = "nmcli --mode tabular --terse connection show --active | grep vpn | cut -d ':' -f1";
          interval = 1;
        };
        cpu = {
          interval = 1;
          format = " {icon0} {icon1} {icon2} {icon3}{usage:>4}% ;";
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
        };
        "memory" = {
          "interval" = 10;
          "format" = "Mem: {used:.2f}/{total:.2f} GiB";
        };
        "temperature" = {
          "critical-threshold" = 80;
          "format" = "{icon} {temperatureC}°C";
          "format-icons" = ["" "" "" "" ""];
        };

        "tray" = {
          "spacing" = 0;
        };

        "custom/menu" = {
          "format" = "";
        };

        "pulseaudio" = {
          "scroll-step" = 5;
          "format" = "{icon}  {volume}%";
          "format-muted" = "   0%";
          "format-icons" = {
            "headphone" = "";
            "headset" = "";
            "portable" = "";
            "default" = ["" "" ""];
          };
          "on-click" = "pavucontrol";
        };
      };
    };

    style = ''

      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 14pt;
        padding: 0 6px;
        color: #208af5;
      }
      tooltip {
          padding: 0;
          border: 2px solid transparent;
          border-radius: 18px;
          background-color: alpha(#1c1c1c, 0.7);
          }

      /* Clear default GTK styling. */
      tooltip * {
          padding: 0;
          margin: 0;
          border: none;
          border-radius: inherit;
          background-color: transparent;
      }

      /* Tooltip Text Box */
      tooltip label {
          padding: 8px;
      }
      .modules-right {
          margin-right: -15px;
      }
      .modules-left {
        margin-left: -15px;
      }
      window#waybar {
        color: #208af5;
        background-color: transparent;
        opacity: 0.98;
        padding: 0;
        border-radius: 10px;
      }
      #workspaces button {
        padding: 0 3px;
        color: #7984A4;
        background-color: transparent;
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }
      #workspaces button.hidden {
        background-color: #002635;
        color: #869696;
      }
      #workspaces button.focused {
        color: #bf616a;
      }

      #workspaces button.active {
        color: #f09b2b;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #clock {
        padding-left: 15px;
        padding-right: 15px;
        margin-top: 0;
        margin-bottom: 0;
        border-radius: 5px;

      }

      #tray {
        color: #a1a19a;
      }

      #custom-menu {
        font-size: 16pt;
        background-color: transparent;
        color: #208af5;
        padding-left: 15px;
        padding-right: 22px;
        margin-left: 0;
        margin-right: 6px;
        margin-top: 0;
        margin-bottom: 0;
        border-radius: 10px;
      }

      #temperature.critical {
        font-weight: bold;
      }
    '';
  };
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      client.focused #5e81accc #1d1f21dd #ffffffff #ffffffff #d5d6e3
      client.unfocused #5e81accc #1c1f2bef #ffffffff #ffffffff #5e81accc
      default_border pixel 1
      default_orientation horizontal
      smart_gaps inverse_outer
    '';
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
      export MOZ_ENABLE_WAYLAND=1
    '';
    checkConfig = false;
    config = let
      modifier = "Mod4";
    in rec {
      bars = [];
      gaps = {
        inner = 7;
        outer = 3;
        smartGaps = true;
        smartBorders = "on";
      };
      window = {
        border = 1;
        titlebar = false;
        commands = [
          {
            command = "inhibit_idle fullscreen";
            criteria = {
              class = "^firefox$";
            };
          }
          {
            command = "inhibit_idle fullscreen";
            criteria = {
              app_id = "^firefox$";
            };
          }
          {
            command = "opacity 0.95, border pixel 3";
            criteria = {
              class = ".*";
            };
          }
          {
            command = "opacity 0.95, border pixel 3";
            criteria = {
              app_id = ".*";
            };
          }
        ];
      };
      startup = [
        {command = "exec waybar";}
      ];
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
          "xkb_layout" = "us,ua";
          "xkb_options" = "ctrl:nocaps,grp:alt_shift_toggle";
        };
      };
      keybindings = {
        "${modifier}+Shift+r" = "reload";
        "${modifier}+a" = "exec ${pkgs.fuzzel}/bin/fuzzel";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+v" = "splitv";
        "${modifier}+b " = "splith";
        "${modifier}+h " = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+k" = "focus up";
        "${modifier}+j" = "focus down";
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+r" = "mode resize";
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+ctrl+p" = "exec ${pkgs.shotman}/bin/shotman -c region";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
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
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  programs.thunderbird = {
    enable = true;
    profiles.personal = {
      isDefault = true;
      settings = {
        "calendar.timezone.local" = "Europe/Kiev";
        "calendar.timezone.useSystemTimezone" = true;
        "datareporting.healthreport.uploadEnabled" = false;
        "mail.incorporate.return_receipt" = 1;
        "mail.markAsReadOnSpam" = true;
        "mail.spam.logging.enabled" = true;
        "mail.spam.manualMark" = true;
        "offline.download.download_messages" = 1;
      };
    };
  };
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    # gtk portal needed to make gtk apps happy
    extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];
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
    profiles.main = {
      search.default = "DuckDuckGo";
      bookmarks = {};
      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "sidebar.verticalTabs" = true;
        "browser.startup.homepage" = "https://start.duckduckgo.com";
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        # Privacy
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.formfill.enable" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.history" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.topsites" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        "places.history.enabled" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.history.custom" = true;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;
        "signon.management.page.breach-alerts.enabled" = false;
        "signon.rememberSignons" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "security.protectionspopup.recordEventTelemetry" = false;
        "security.identitypopup.recordEventTelemetry" = false;
        "security.certerrors.recordEventTelemetry" = false;
        "security.app_menu.recordEventTelemetry" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.pioneer-new-studies-available" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "browser.tabs.firefox-view" = false;
      };
    };

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;

      ExtensionSettings = {
        "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
        "google@search.mozilla.org".installation_mode = "blocked";
        "bing@search.mozilla.org".installation_mode = "blocked";
        "amazondotcom@search.mozilla.org".installation_mode = "blocked";
        "ebay@search.mozilla.org".installation_mode = "blocked";
        "wikipedia@search.mozilla.org".installation_mode = "blocked";
        "browserpass@maximbaz.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4468825/browserpass_ce-3.10.2.xpi";
          installation_mode = "force_installed";
        };
        "tprb.addon@searxes.danwin1210.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4275924/tprb-1.1.21.2resigned1.xpi";
          installation_mode = "force_installed";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
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

  programs.gpg = {
    enable = true;
    settings = {
      use-agent = true;
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        prompt = "❯ ";
        icon-theme = "Papirus-Dark";
        font = "JetBrains Mono:weight=bold:size=14";
        dpi-aware = "no";
        width = 50;
        horizontal-pad = 8;
        vertical-pad = 8;
        filter-desktop = "yes";
        list-executables-in-path = "no";
        show-actions = "no";
        lines = 12;
        exit-on-keyboard-focus-loss = "yes";
      };

      colors = {
        background = "1d1f21dd";
        border = "5e81accc";
        text = "a6accdff";
        match = "c792eacc";
        selection = "a6accdff";
        selection-text = "232635ff";
      };

      border = {
        radius = 25;
      };
    };
  };

  programs.direnv.enable = true;
  services.gnome-keyring.enable = true;
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck"];
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
