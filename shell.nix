{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
  buildInputs = [
    pkgs.argbash
    pkgs.gnumake
  ];
}
