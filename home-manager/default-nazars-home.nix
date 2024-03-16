{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.hm.gvariant) mkTuple;
in {
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
      fractal
      telegram-desktop
      gnome.gnome-tweaks
      nodejs
    ];
  };

  # Add stuff for your user as you see fit:
  programs.home-manager.enable = true;
  programs.browserpass = {
    enable = true;
    browsers = ["firefox"];
  };

  programs.vscode = {
  package = pkgs.vscodium;
  enable = true;
  extensions = with pkgs.vscode-extensions; [
    jnoortheen.nix-ide
  ];
};


  accounts.email.accounts = {
    personal = {
      primary = true;
      address = "nazarn96@gmail.com";
      realName = "Nazar Klovanych";
      userName = "klovanych";
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.personal = {
      isDefault= true;
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
      bookmarks = { };
      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
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
          Value= true;
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
          # Privacy Badger:
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          "browserpass@maximbaz.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4187654/browserpass_ce-3.8.0.xpi";
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

  services.gpg-agent ={
    enable = true;
    pinentryFlavor = "gnome3";
  };

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
    };
  };


  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };

    "org/gnome/desktop/input-sources" = { 
      show-all-sources = true;
      per-window = true;
      sources = [
          (mkTuple ["xkb" "us"])
          (mkTuple ["xkb" "ua"])
      ];
      xkb-options = ["caps:ctrl_modifier"];
    };
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/pixels-l.jpg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/pixels-d.jpg";
      primary-color = "#967864";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
    };
  };

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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
