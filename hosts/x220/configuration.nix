{
  imports = [
    ../t440p/configuration.nix
  ];

  # Config definitions.
  services.othermodule.enable = true;
  # ...
  # Notice that you can leave out the "config { }" wrapper.
}