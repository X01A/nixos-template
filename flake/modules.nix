{ inputs, ... }:

{
  flake.nixosModules = {
    default =
      { ... }:
      {
        imports = inputs.self.lib.self.mapModulesRec' ../modules (it: it);
      };
  };
}
