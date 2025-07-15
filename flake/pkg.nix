{ inputs, self, ... }:

{
  perSystem =
    {
      config,
      pkgs,
      self',
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          (prev: curr: { inherit (inputs.disko.packages."${curr.system}") disko; })

          self.overlays.default
          inputs.colmena.overlays.default
        ];
      };
    };
}
