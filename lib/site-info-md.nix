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
  | ID | Type | Board | Host | SSH Endpoint |
  |----|------|-------|------|--------------|
  ${
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (supervisorId: siteSupervisor: let
        supervisor = supervisors."${supervisorId}";
        shortId = "${builtins.substring 0 8 supervisorId}";
        type = typeMap."${supervisor.type}";
        board = "${supervisor.board.manufacturer} ${supervisor.board.model}";
        host =
          if supervisor.type == "nbd_netboot" then
            supervisor.nbd_netboot_host.model
          else if supervisor.type == "nbd_netboot_static" then
            supervisor.nbd_netboot_host.model
          else if supervisor.type == "qemu" then
            ""
          else
            builtins.throw "Unknown supervisor host for type ${supervisor.type}";
        sshEndpoint =
          if supervisor.type == "nbd_netboot" then
            "sns30.cs.princeton.edu:${builtins.toString siteSupervisor.nbd_netboot_host_ip4.ssh_forward_host_port}"
          else if supervisor.type == "nbd_netboot_static" then
            ""
          else if supervisor.type == "qemu" then
            "sns30.cs.princeton.edu:${builtins.toString siteSupervisor.qemu_host_ip4.ssh_forward_host_port}"
          else
            builtins.throw "Unknown SSH endpoint for type ${supervisor.type}";
      in
        "| <a href=\"#board-${supervisorId}\" title=\"${supervisorId}\">${shortId}...</a> | ${type} | ${board} | ${host} | ${sshEndpoint} |"
      ) sites."${site}".supervisors
    )
  }
''


