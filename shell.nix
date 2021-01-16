{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    (import ./default.nix).psgo
  ];

  shellHook = ''
    export GOPATH="$PWD/go"
  '';
}
