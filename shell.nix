{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
  inputsFrom = [ (pkgs.callPackage ./. { inherit pkgs; }) ];

  nativeBuildInputs = with pkgs; [
    fpm
    libarchive
    rpm
  ]; 
}
