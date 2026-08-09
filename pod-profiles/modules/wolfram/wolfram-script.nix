{ system, stdenv, dpkg, glibc, gcc-unwrapped, autoPatchelfHook }:
let
  version = "15.0.0";

  src = ./WolframScript_15_LINUX64_amd64.deb;
in stdenv.mkDerivation {
  name = "wolframscript-${version}";

  inherit src system;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    cp -av $out/opt/Wolfram/WolframScript/* $out
    rm -rf $out/opt
  '';

  meta = with stdenv.lib; {
    description = "Wolframscript";
    homepage = https://www.wolfram.com/wolframscript/;
    license = licenses.mit;
    maintainers = with stdenv.lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
