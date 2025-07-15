{
  perSystem =
    {
      inputs,
      config,
      pkgs,
      self,
      ...
    }:
    {
      devshells.default = {
        commands = [
          {
            package = pkgs.nix-output-monitor;
            category = "deploy";
          }
          {
            package = pkgs.nixfmt-rfc-style;
            category = "format";
          }
          {
            package = pkgs.colmena;
            category = "deploy";
          }
          {
            package = pkgs.sops;
            category = "secrets";
          }
          {
            package = pkgs.age-plugin-yubikey;
            category = "secrets";
          }
          {
            category = "secrets";
            name = "sops-update-keys";
            help = "Update keys for all sops file";
            command = ''
              set -e

              ${pkgs.fd}/bin/fd '.*\.yaml' $PRJ_ROOT/secrets --exec sops updatekeys --yes
            '';
          }
          {
            category = "secrets";
            name = "sops-scan-host";
            help = "Scan host sops key";
            command = ''
              set -e

              ${pkgs.openssh}/bin/ssh-keyscan $1 | ${pkgs.gnugrep}/bin/grep -v "^#" | ${pkgs.ssh-to-age}/bin/ssh-to-age
            '';
          }
          {
            package = pkgs.ssh-to-age;
            category = "secrets";
          }
          {
            package = pkgs.age;
            category = "secrets";
          }

          {
            package = pkgs.python3.withPackages (
              python-packages: with python-packages; [
                requests
              ]
            );
            category = "deploy";

          }
        ];
      };
    };
}
