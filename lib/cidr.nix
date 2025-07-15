{ lib, self, ... }:

with builtins;

let
  inherit (self.math) pow mod;
in
rec {
  parseIp = str: map lib.toInt (builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)" str);
  prettyIp = lib.concatMapStringsSep "." toString;

  ipToLong =
    ip:
    let
      first = elemAt ip 0;
      second = elemAt ip 1;
      third = elemAt ip 2;
      fourth = elemAt ip 3;
    in
    first * (pow 256 3) + second * (pow 256 2) + third * 256 + fourth;

  longToIp =
    long:
    let
      first = mod long 256;
      second = mod (div long 256) 256;
      third = mod (div long (pow 256 2)) 256;
      fourth = mod (div long (pow 256 3)) 256;
    in
    [
      fourth
      third
      second
      first
    ];

  nextIp = ip: longToIp ((ipToLong ip) + 1);

  cidrToMask =
    let
      # Generate a partial mask for an integer from 0 to 7
      #   part 1 = 128
      #   part 7 = 254
      part = n: if n == 0 then 0 else part (n - 1) / 2 + 128;
    in
    cidr:
    let
      # How many initial parts of the mask are full (=255)
      fullParts = cidr / 8;
    in
    lib.genList (
      i:
      # Fill up initial full parts
      if i < fullParts then
        255
      # If we're above the first non-full part, fill with 0
      else if fullParts < i then
        0
      # First non-full part generation
      else
        part (lib.mod cidr 8)
    ) 4;

  parseSubnet =
    str:
    let
      splitParts = builtins.split "/" str;
      givenIp = parseIp (lib.elemAt splitParts 0);
      cidr = lib.toInt (lib.elemAt splitParts 2);
      mask = cidrToMask cidr;
      baseIp = lib.zipListsWith lib.bitAnd givenIp mask;
      range = {
        from = baseIp;
        to = lib.zipListsWith (b: m: 255 - m + b) baseIp mask;
      };
      check = ip: baseIp == lib.zipListsWith (b: m: lib.bitAnd b m) ip mask;
      warn =
        if baseIp == givenIp then
          lib.id
        else
          lib.warn (
            "subnet ${str} has a too specific base address ${prettyIp givenIp}, "
            + "which will get masked to ${prettyIp baseIp}, which should be used instead"
          );
    in
    warn {
      inherit
        baseIp
        cidr
        mask
        range
        check
        ;
      subnet = "${prettyIp baseIp}/${toString cidr}";
    };
}
