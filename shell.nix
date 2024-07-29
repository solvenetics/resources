{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.unixODBC
    pkgs.python39
    pkgs.python39Packages.pyodbc
  ];
}
