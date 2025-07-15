{ inputs, ... }:

let
  inherit (inputs) nixpkgs self;

  hosts = self.lib.self.modules.mapModules ../hosts (
    name:
    {
      config,
      lib,
      nodes,
      ...
    }:
    {
      imports = [
        name
        self.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.sops.nixosModules.sops
        inputs.indexyz.nixosModules.indexyz
      ];

      system.stateVersion = "23.05";
      nix.registry.nixpkgs.flake = inputs.nixpkgs;

      nix = {
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

        settings.substituters = [
          "https://indexyz.cachix.org"
        ];

        settings.trusted-public-keys = [
          "indexyz.cachix.org-1:biBEnuZ4vTSsVMr8anZls+Lukq8w4zTHAK8/p+fdaJQ="
        ];
      };

      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sops-file.directory = ../secrets;
    }
  );
in
{
  flake.colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;

  flake.colmena = {
    meta = {
      name = "gravity";

      specialArgs = {
        flakeInputs = inputs;
        inherit inputs;
      };

      description = "hosts infrastucture";
      nixpkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          (prev: curr: { inherit (inputs.disko.packages."${curr.system}") disko; })
          inputs.self.overlays.default
          inputs.indexyz.overlays.default
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
  } // hosts;
}
