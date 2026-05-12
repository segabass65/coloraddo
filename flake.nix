{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, utils, systems, ... }:
    utils.lib.eachSystem  (import systems) (system: let
      pkgs = import nixpkgs { inherit system; };

    in {
      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/coloraddod";
      };
      
      devShells.default = import ./shell.nix { inherit pkgs; };
      packages.default = pkgs.callPackage ./. { inherit pkgs; };
    });
}
