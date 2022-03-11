{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    edid-generator = {
      url = "github:akatrevorjay/edid-generator";
      flake = false;
    };
  };

  outputs = { self, flake-utils, edid-generator, nixpkgs, ... }@inputs:
    flake-utils.lib.eachDefaultSystem ( system:
      let
        lib = nixpkgs.lib;
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs ; [
            edid-decode
            wxhexeditor
            edid-generator
              xorg.xorgserver # for cvt
              gnumake
              dos2unix
          ];
        };
      }
    );
      
}
