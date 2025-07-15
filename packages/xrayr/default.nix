{ fetchFromGitHub, buildGoModule, ... }:

buildGoModule rec {
  name = "xrayr";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "Anankke";
    repo = "XrayRF";
    rev = "53507e96b0ed2f5ff7d737965bb56f8fa51135f6";
    sha256 = "sha256-x75IVqNU90pmQCaICBLKCcq15O3Et+CsBRc7lU64HV0=";
  };

  doCheck = false;
  subPackages = [ "." ];
  vendorHash = "sha256-d2cW8gHQ1BUJ0JnNTVMMW1ACz8G2LYMbjymkQNCc/7Q=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta.mainProgram = "XrayR";
}
