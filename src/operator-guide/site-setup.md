# Setting up a New Treadmill Site

This guide outlines how to set up a new treadmill site.

A treadmill site hosts one or more [Treadmill Hosts and
DUTs](../introduction/terminology.md). It requires at least one server to host
the [Supervisors](../introduction/terminology.md) responsible for controlling
the Treadmill Hosts. Depending on the number and types of hosts and DUTs, it
might require additional components, such as:

- for netboot-based Treadmill Hosts, a PoE-capable network switch,
- for physical (non-VM-based) Treadmill Hosts, the physical host hardware such
  as a Raspberry Pi.

In this guide, we illustrate the process of setting up a new Treadmill site
consisting of a single server to host supervisors. The site provides two hosts:

- a Virtual Machine-based Treadmill host running on the above server attached to
  a ChipWhisperer CW310 FPGA DUT via USB, and
- a Raspberry Pi host connected to a Nordic Semicondutor nRF52840DK DUT, powered
  by a PoE-capable network switch.

## Bill of Materials

We use the following equipment for this guide. Price estimates are of
2025-06-20. Depending on the size of the setup it may make sense to choose
different components.

- **The site server.**

  Any reasonably powerful x86-based host capable of running NixOS, with at least
  two network interfaces should work. In our example, we use a Minisforum MS-01
  with an Intel Core i9-12900H CPU, 32GB RAM and a 1TB SSD.

  **Minisforum MS-01: $695.00**

- **A PoE-capable network switch.**

  The network switch must have at least one PoE-enabled port with sufficient
  power output for each PoE-powered Treadmill Host. It must be capable of
  VLAN-tagging and feature a "trunk port" that can be attached to the site
  server. The switch must be able to control the PoE enable state per port
  remotely in an automated fashion (such as using automated SSH commands). A
  site can have multiple switches, shared by one or more site servers.

  In our setup, we plan on hosting a larger number of PoE-powered Treadmill
  hosts at the site. Therefore, we opt for a switch that features a large number
  of PoE-enabled ports, and one that can supply sufficient power for many
  Treadmill hosts to be running at the same time.

  **Mikrotik CRS328-24P-4S+RM: $492.14**

  Additional equipment:
  - SFP+ DAC cable (6ft, for 10G trunk link between site server and switch):
    ~$20
  - USB Console Cable (compatible to Cisco switches): ~$10

- **Host and DUT Hardware**

  The (physical) Treadmill hosts and DUTs to attach to the system.

  For the Raspberry Pi 5 with an nRF5280DK:
  - Raspberry Pi 5, 8GB: $96.79
  - 52Pi P30 PoE+ HAT for Raspberry Pi 5 with active cooler (retains physical
    access to GPIOs): $29.99
  - nRF52840DK DUT board: $49.00
  - CAT6 Ethernet cable
  - Micro-USB cable
  - (optional) Raspberry Pi Debug Probe (for serial console access to Raspberry
    Pi host): $15.99

## Installing NixOS onto the Site Server

TODO

```
[root@tml-pton-srv1:~]# nix-shell -p age --run "age-keygen -o /var/state/age-site-key.txt"
Public key: age14xsnkcumdjf6ue8ske08mvg25qj8lwx6pdahjrm97umr5smyxu8sqs2e4v
```

## Adding the Site Server to the Deployments Repository

1. Clone the `deployments` repository:

   ```
   $ git clone git@github.com:treadmill-tb/deployments.git
   ```

2. Add the new site server to the list of nodes in `flake.nix`:

   ```diff
       deployment = {
           targetHost = "tml-pton-srv0.princeton.edu";
         };
       };
   +
   +   pton-srv1 = { ... }: {
   +     imports = [
   +       ./sites/pton-srv1
   +     ];
   +
   +     deployment = {
   +       targetHost = "tml-pton-srv1.princeton.edu";
   +     };
   +   };
     };
   ```

3. Create a new directory: `sites/pton-srv1`

4. Generate your own `age` key. Add both your own and the site's public key to
   the `.sops.yaml` file, and add a creation rules for the site's subdirectory:

   TODO

5. Generate a new root password and store it (encrypted) in the repository:

   ```
   $ nix-shell -p pwgen mkpasswd age sops
   $ pwgen -1 24 1 \
       | sed 's/^/PASSWORD=/' \
	   | sops encrypt --filename-override=sites/pton-srv1/secrets/root-password.env \
	   > sites/pton-srv1/secrets/root-password.env
   $ SOPS_AGE_KEY_FILE=../age-key.txt sops -d \
       --extract '["PASSWORD"]' sites/pton-srv1/secrets/root-password.env \
	   | mkpasswd --stdin -m sha-512
   $6$ePOr1QeA6f.vL1Y0$vGWwboKJfLmFYjmVWKaSx0liE9RIH7GAP8KyawpvdXCP03r1qFtLNHcIBB8Jo7/NBQdTZ/gXbGNJ1AXjiP/qA1
   ```

1. TODO

   ```
   $ nix-shell -p wireguard-tools sops age
   $ wg genkey \
       | sed 's/^/WIREGUARD_PRIVKEY=/' \
	   | sops encrypt --filename-override=sites/pton-srv1/secrets/mullvad-wireguard-key.env \
	   > sites/pton-srv1/secrets/mullvad-wireguard-key.env
   $ SOPS_AGE_KEY_FILE=../age-key.txt sops -d \
       --extract '["WIREGUARD_PRIVKEY"]' sites/pton-srv1/secrets/mullvad-wireguard-key.env \
	   | wg pubkey
   vdNAKPfOr3yYwfOnA8Vm2yZFBfaRE7fJE6WtxLr3Ln4=
   ```

   Calculate the public key from the private key, and add it to the Mullvad
   account, then copy the IPv4 & IPv6 addresses into the configuration.

4. Create a file `sites/pton-srv1/default.nix` by merging the generated NixOS
   configuration and hardware configuration
   (`/etc/nixos/{configuration,hardware-configuration}.nix`). The configuration
   should end up looking similar to the other nodes defined in this repository.

   Set `users.users.root.hashedPassword` to the above password.
