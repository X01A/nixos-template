{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:5aaee9/nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    colmena.url = "github:zhaofengli/colmena";
    flake-utils.url = "github:numtide/flake-utils";
    indexyz = {
      url = "github:X01A/nixos";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "indexyz/nixpkgs";
    };

    nixago = {
      url = "github:jmgilman/nixago";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule

        ./flake/pkg.nix
        ./flake/dev.nix
        ./flake/hosts.nix
        ./flake/modules.nix
        ./flake/packages.nix
        ./flake/nixago.nix
        ./flake/lefthook.nix
        ./flake/treefmt.nix
        ./lib
      ];
    };
}
