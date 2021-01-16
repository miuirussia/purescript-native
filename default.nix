let
  sources = import ./nix/sources.nix;
  haskell-nix = import sources."haskell.nix" {};
  nixpkgsArgs = haskell-nix.nixpkgsArgs // {
    config = {};
    overlays = haskell-nix.nixpkgsArgs.overlays ++ [
      (
        self: super: {
          haskell-nix = super.haskell-nix // {
            compiler = super.haskell-nix.compiler // {
              ghc865 = super.haskell-nix.compiler.ghc865.overrideAttrs (
                prev: {
                  src = prev.src.overrideAttrs (
                    prevSrc: {
                      patches = prevSrc.patches ++ [
                        ./patches/fix-ghc865.patch
                      ];
                    }
                  );
                }
              );
            };
          };
        }
      )
    ];
  };
  iohk = (import sources.nixpkgs nixpkgsArgs).pkgs.haskell-nix;
  pkgs = import sources.nixpkgs {};
  pkgsSet = (
    iohk.stackProject {
      src = sources.purescript-native;
      pkg-def-extras = [
        (hackage: { hsc2hs = hackage.hsc2hs."0.68.4".revisions.default; })
      ];
      sha256map = {
        "https://github.com/purescript/purescript"."9cad73ed8ea7df3011032ddbd2f3de5a0c08629c" = "0mlgww6j8nfdgy6x7l6z5in37r6qs11wnxf1cpgqaiyabadaik20";
      };
    }
  );
  psgo = pkgs.symlinkJoin {
    name = "psgo";
    paths = [
      pkgsSet.psgo.components.exes.psgo
      pkgs.go
    ];
    postBuild = ''
      ln -s $out/share/go/bin/go $out/bin/go
      ln -s $out/share/go/bin/gofmt $out/bin/gofmt
    '';
  };
in {
  inherit psgo;
}

