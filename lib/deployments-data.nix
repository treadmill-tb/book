{ pkgs ? import <nixpkgs> {} }:

# To update the deployments repo (also running on GitHub nightly CI):
# nix-prefetch-git --url https://github.com/treadmill-tb/deployments.git --rev refs/heads/main > deployments-data.json

let
  deploymentsGit = builtins.fromJSON (builtins.readFile ./deployments-data.json);

  deploymentsSrc = builtins.fetchGit {
    inherit (deploymentsGit) url rev;
    ref = "refs/heads/main";
  };

  deploymentsCombined = import "${deploymentsSrc}/lib/combined.nix" {};

in
  deploymentsCombined
