{ lib }:

let
  ownedKeys = [
    # Generate sops keys
  ];

  hosts = {

  };

  allHostKeys = lib.mapAttrsToList (_: cfg: cfg.key) hosts;

  mkNamedCreationRule = name: key: {
    path_regex = "^secrets/${name}(\.plain)?\.yaml$";
    key_groups = [ { age = lib.lists.flatten (ownedKeys ++ [ key ]); } ];
  };

  hostsCreateionRule = map (it: mkNamedCreationRule "hosts/${it.key}" it.value.key) (
    lib.mapAttrsToList (key: value: { inherit key value; }) hosts
  );
in
{
  creation_rules = [ ] ++ hostsCreateionRule;
}
