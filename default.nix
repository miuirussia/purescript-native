{ pkgs ? import <nixpkgs> {} }:

let
  sources = import ./nix/sources.nix;
  haskell-nix = import sources."haskell.nix" {};
  iohk = (import sources.nixpkgs haskell-nix.nixpkgsArgs).pkgs.haskell-nix;
  pkgs = import sources.nixpkgs { };
  pkgsSet = (iohk.stackProject {
    src = sources.purescript-native;
    pkg-def-extras = [
      (hackage: { hsc2hs = hackage.hsc2hs."0.68.4".revisions.default; })
    ];
    modules = [
      {
        packages.purescript.components.library.build-tools = [pkgs.darwin.apple_sdk.frameworks.Cocoa];
      }
    ];
    sha256map = {
      "https://github.com/purescript/purescript"."9cad73ed8ea7df3011032ddbd2f3de5a0c08629c" = "0mlgww6j8nfdgy6x7l6z5in37r6qs11wnxf1cpgqaiyabadaik20";
    };
  });
in pkgs.symlinkJoin {
  name = "purescript-native";
  paths = with pkgs; [
    go
    pkgsSet.psgo.components.exes.psgo
  ];

}
