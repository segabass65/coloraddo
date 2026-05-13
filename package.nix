{
  lib,
  stdenv,
  argbash,
  bspwm,
  coreutils,
  gnumake,
  makeWrapper,
  procps,
  wmutils-core,
  xtitle
} @ args:

  stdenv.mkDerivation {
    pname = "coloraddo";
    version = "1.0";
    src = ./.;

    nativeBuildInputs = [
      argbash
      gnumake
      makeWrapper
    ];

    buildInputs = import ./depends/nixpkgs.nix { inherit args; };

    installPhase = ''
      runHook preInstall

      make install DESTDIR="$out" PREFIX=

      wrapProgram "$out/bin/coloraddod" \
        --prefix PATH : ${
          lib.makeBinPath (import ./depends/nixpkgs.nix { inherit args; })
        }

      runHook postInstall
    '';

    meta = with lib; {
      description = "Changing border colors depending on bspwm node flags";
      homepage = "https://github.com/segabass65/coloraddo";
      license = licenses.mit;
      maintainers = [ "segabass65 <segabass65@proton.me>" ]; 
      platforms = platforms.linux;
    };
}
