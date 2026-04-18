{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    argbash
    gnumake
  ];
}
