{ inputs, lib, ... }:

{
  imports = [ ./nixago-option.nix ];

  perSystem =
    { config, ... }:
    {
      nixago.configs = [
        {
          output = ".sops.yaml";
          format = "yaml";
          data = import ./sops-yaml.nix { inherit lib; };
        }
      ];

      devshells.default.devshell.startup."00-nixago".text = config.nixago.shellHook;
    };
}
