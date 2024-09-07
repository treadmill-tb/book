{ pkgs ? import <nixpkgs> {} }:

let
  deploymentsGit = builtins.fromJSON (builtins.readFile ./deployments-data.json);

  deploymentsSrc = builtins.fetchGit {
    inherit (deploymentsGit) url rev;
    ref = "refs/heads/main";
  };

  deploymentsCombined = import "${deploymentsSrc}/lib/combined.nix" {};

in
  deploymentsCombined
