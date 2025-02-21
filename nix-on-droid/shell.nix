{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "my-dev-shell";

  buildInputs = [
    pkgs.python3
    pkgs.neovim
  ];

  shellHook = ''
    echo "Python 3 and Neovim are available in this shell."
  '';
}

