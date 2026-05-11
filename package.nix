{ lib, stdenv, argbash, gnumake, makeWrapper, wmutils-core, xtitle }:
  stdenv.mkDerivation rec {
    pname = "coloraddo";
    version = "1.0";
    src = ./.;

    nativeBuildInputs = [
      argbash
      gnumake
      makeWrapper
    ];

    buildInputs = [
      wmutils-core
      xtitle
    ];

    installPhase = ''
      runHook preInstall

      make install DESTDIR="$out" PREFIX=

      wrapProgram "$out/bin/coloraddod" \
        --prefix PATH : ${lib.makeBinPath [ xtitle wmutils-core ]}

      runHook postInstall
    '';

    meta = with lib; {
      description = "Changing border colors depending on bspwm node flags";
      homepage = "https://github.com/segabass65/coloraddo";
      license = licenses.mit;
      maintainers = [ "segabass65 <segabass65@proton.me>" ]; 
      platforms = platforms.unix;
    };
}
