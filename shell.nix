{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    argbash
    fpm
    gnumake
    wmutils-core
    xtitle
  ];
}
