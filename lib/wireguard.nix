{ self, lib, ... }:

let
  inherit (self.attrs) attrsToList mapFilterAttrs;
  inherit (lib) nameValuePair;
  inherit (builtins) filter map;
in
rec {
  generatePeerMatrix =
    filter: nodes:
    attrsToList (
      mapFilterAttrs (n: v: n != filter.selfName && v.enable && filter.group == v.group) (
        n: v:
        nameValuePair n (
          let
            wireguard = v.config.betaidc.network.wireguard;
          in
          {
            inherit (wireguard)
              enable
              publicAddr
              publicPort
              meshAddress
              privateKey
              group
              ;
          }
        )
      ) nodes
    );
}
