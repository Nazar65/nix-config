{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
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
