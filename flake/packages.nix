{ inputs, ... }:

{
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem =
    {
      inputs',
      config,
      pkgs,
      self',
      ...
    }:
    rec {
      packages = rec {
        dnsforward = pkgs.callPackage ../packages/dnsforward { };
        xrayr = pkgs.callPackage ../packages/xrayr { };
        flexcdn-admin = pkgs.callPackage ../packages/flexcdn-admin { };
        flexcdn-node = pkgs.callPackage ../packages/flexcdn-node { };
        flexcdn-dns = pkgs.callPackage ../packages/flexcdn-dns { };
      };
      overlayAttrs = packages;
    };
}
