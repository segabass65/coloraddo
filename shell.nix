{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
  buildInputs = with pkgs; [
    argbash
    gnumake
  ];
}
