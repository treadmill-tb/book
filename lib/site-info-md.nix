{ pkgs ? import <nixpkgs> {}
, site
}:

with pkgs;

let
  data = import ./deployments-data.nix { inherit pkgs; };
  supervisors = data.supervisors;
  sites = data.sites;

  typeMap = {
    "nbd_netboot" = "Netboot (NBD)";
    "nbd_netboot_static" = "Netboot (Static NBD Image)";
    "qemu" = "QEMU VM";
  };

in
pkgs.writeText "deployments-info-${site}.md" ''
  | ID | Type | Board | Host |
  |----|------|-------|------|
  ${
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (supervisorId: siteSupervisor: let
        supervisor = supervisors."${supervisorId}";
        shortId = "${builtins.substring 0 8 supervisorId}";
        type = typeMap."${supervisor.type}";
        board = "${supervisor.board.manufacturer} ${supervisor.board.model}";
        host =
          if supervisor.type == "nbd_netboot_host" then
            supervisor.nbd_netboot_host.model
          else if supervisor.type == "nbd_netboot_static" then
            supervisor.nbd_netboot_host.model
          else if supervisor.type == "qemu" then
            ""
          else
            builtins.throw "Unknown supervisor host for type ${supervisor.type}";
      in
        "| <a href=\"#board-${supervisorId}\" title=\"${supervisorId}\">${shortId}...</a> | ${type} | ${board} | ${host} |"
      ) sites."${site}".supervisors
    )
  }
''


