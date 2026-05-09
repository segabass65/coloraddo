{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    argbash
    fpm
    gnumake
    libarchive
    rpm
    wmutils-core
    xtitle
  ];
}
