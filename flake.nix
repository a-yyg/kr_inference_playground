{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      kissat-overlay = final: prev: {
        kissat = prev.kissat.overrideAttrs
          (oldAttrs: rec {
            version = "4.0.1";
            src = prev.kissat.src.override {
              owner = "arminbiere";
              repo = "kissat";
              rev = "rel-${version}";
              sha256 = "sha256-+y9TlSEgnMTtRT9F6OBSle9OqGfljChcHOFJ5lgwjyk=";
            };
          });
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ kissat-overlay ];
      };

      sugar = pkgs.callPackage ./sugar.nix {};
    in
    {
      packages.sugar = sugar;
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          kissat
          clingo
          sugar
          # zulu8
          jre8
        ];
      };
    }
  );
}

