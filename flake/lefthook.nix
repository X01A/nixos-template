{ inputs, lib, ... }:

let
  lefthookConfig = {
    pre-commit = {
      parallel = true;
      commands = {
        nixfmt = {
          run = "nix fmt";
          stage_fixed = true;
        };
        update-keys = {
          run = "sops-update-keys";
          stage_fixed = true;
        };
      };
    };
  };
in
{
  perSystem =
    { config, pkgs, ... }:
    {
      nixago.configs = [
        {
          output = "lefthook.yml";
          format = "yaml";
          data = lefthookConfig;
        }
      ];

      devshells.default.devshell.startup."lefthook".text = ''
        ${pkgs.lefthook}/bin/lefthook install
      '';
    };
}
