{ lib
, stdenv
, jdk8
, jre8
, fetchFromGitLab
, gnumake
, perl
, glucose
, makeWrapper
, version ? "2.3.4"
}:

stdenv.mkDerivation {
  pname = "sugar";
  inherit version;
  src = fetchFromGitLab {
    owner = "cspsat";
    repo = "prog-sugar";
    rev = "v${version}";
    sha256 = "sha256-Rk0A6u3dB4ayDBP9EpeaGZIvKXAEi2DMJQg22LbE4Po=";
  };

  nativeBuildInputs = [ gnumake jdk8 makeWrapper ];

  preBuild = ''
    substituteInPlace Makefile \
      --replace-fail "BINDIR = /usr/local/bin" "BINDIR = $out/bin" \
      --replace-fail "LIBDIR = /usr/local/lib/$(APP0)" "LIBDIR = $out/lib/$(APP0)"

    substituteInPlace sugar \
      --replace-fail "usr/local" "$out"

    mkdir -p ./classes
  '';

  buildPhase = ''
    runHook preBuild
    make javac jar
    make install
  '';

  postInstall = ''
    mkdir -p $out/share/doc/sugar
    cp -r docs/* $out/share/doc/sugar
    mkdir -p $out/share/examples/sugar
    cp -r examples/* $out/share/examples/sugar
    mkdir -p $out/share/tools/sugar
    cp -r tools/* $out/share/tools/sugar

    wrapProgram $out/bin/sugar \
      --prefix PATH : ${glucose}/bin \
      --prefix PATH : ${jre8}/bin \
      --prefix PATH : ${perl}/bin
  '';
}
