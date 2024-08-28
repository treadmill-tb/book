# 5. Deployments

Treadmill deployments are configurations that define the structure and setup of your test environment. This chapter will guide you through the process of setting up and managing Treadmill deployments using the provided configuration files.

## 5.1 Deployment Structure

Treadmill deployments are defined using a combination of Nix files that describe the overall system configuration, individual supervisors, and site-specific settings. The main components of a deployment are:

1. Combined configuration
2. Module configuration
3. Site-specific configuration
4. Supervisor-specific configurations

### 5.1.1 Combined Configuration

The `combined.nix` file aggregates all supervisor and site configurations into a single structure. It reads the supervisor and site configuration files from their respective directories and combines them into a unified data structure.

### 5.1.2 Module Configuration

The `module.nix` file defines the NixOS module that sets up the Treadmill environment. It includes functions for generating configurations for different types of supervisors, such as NBD netboot and QEMU-based supervisors.

### 5.1.3 Site Configuration

Site configuration files (e.g., `pton-srv0.nix`) define the network setup for a specific deployment site. They include information about switches, VLANs, and IP addressing for supervisors.

### 5.1.4 Supervisor Configurations

Individual supervisor configuration files define the specifics of each supervisor, including its type (e.g., NBD netboot or QEMU), hardware details, and associated board information.

## 5.2 Setting Up a Deployment

To set up a Treadmill deployment, follow these steps:

1. Define your site configuration in a new `.nix` file under the `sites/` directory.
2. Create supervisor configuration files for each supervisor in your deployment under the `supervisors/` directory.
3. Update the `combined.nix` file if necessary to include any new configuration files.
4. Use the `module.nix` file to generate the NixOS configuration for your deployment.

### 5.2.1 Example: Setting up an NBD Netboot Supervisor

Here's an example of setting up an NBD netboot supervisor:

1. Create a supervisor configuration file (e.g., `supervisors/524aa422-3ea7-47be-99d3-b78430449589.nix`):

```nix
{
  id = "524aa422-3ea7-47be-99d3-b78430449589";
  type = "nbd_netboot_static";

  nbd_netboot_host = {
    model = "Raspberry Pi 5 8GB";
    pxe_profile = "raspberrypi";
    serial_no = "";
    mac_addr = "2c:cf:67:09:60:6c";
  };

  nbd_netboot_static = {
    root_base_image = "/var/lib/treadmill/store/blobs/58/7f/b3/587fb3c958b30607cae8cbc12a4311ecf2abeeb51344af2ce0f15bb86eea6f6a";
    root_dev_size = "64G";
    boot_archive = "/var/lib/treadmill/store/blobs/b1/d8/40/b1d840cd148760a8d10c216736e0df737341ea4044649365ab4516a2b5e89e9b";
  };

  nbd_netboot_console = {
    udev_filters = [
      "ENV{ID_MODEL}==\"Debug_Probe__CMSIS-DAP_\""
      "ENV{ID_USB_SERIAL_SHORT}==\"E6633861A354302C\""
    ];
    baudrate = 115200;
  };

  board = {
    manufacturer = "Nordic Semiconductor";
    model = "nRF52840DK";
    hwrev = "";
    serial_no = "";
  };
}
```

2. Update your site configuration (e.g., `sites/pton-srv0.nix`) to include the new supervisor:

```nix
{
  switches."pton-srv0-sw0" = {
    trunk_supervisor_netdev = "enp3s0";
  };

  supervisors = {
    "524aa422-3ea7-47be-99d3-b78430449589" = {
      nbd_netboot_host_switch = "pton-srv0-sw0";
      nbd_netboot_host_port = "ge-0/0/1";
      nbd_netboot_host_vlan = 1000;
      nbd_netboot_host_ip4 = {
        network = "172.17.193.0";
        prefixlen = 30;
        supervisor_addr = "172.17.193.1";
        addr = "172.17.193.2";
      };
    };
    // ... other supervisors ...
  };
}
```

## 5.3 Supervisor Types

Treadmill supports different types of supervisors, each with its own configuration requirements:

1. NBD Netboot (`nbd_netboot` and `nbd_netboot_static`)
2. QEMU (`qemu`)

### 5.3.1 NBD Netboot Supervisors

NBD netboot supervisors are typically used for physical devices that boot over the network. They require configuration for PXE booting, network settings, and console access.

### 5.3.2 QEMU Supervisors

QEMU supervisors are used for virtualized environments. They require configuration for virtual machine settings, network bridges, and USB device passthrough.

## 5.4 Network Configuration

Treadmill deployments use VLANs and bridges to isolate network traffic between supervisors. The `module.nix` file generates the necessary network configuration based on the site and supervisor settings.

For NBD netboot supervisors, it sets up VLAN interfaces and DHCP servers. For QEMU supervisors, it creates network bridges for VM connectivity.

## 5.5 Image Management

Treadmill uses a content-addressed store for managing images. The `nbd_netboot_static` configuration specifies the locations of root base images and boot archives. These images are used to boot the supervised devices or virtual machines.

(Note: See ./Image-Store.md for more information)

## 5.6 Console Access

For physical devices, console access is configured using udev rules. The `nbd_netboot_console` section in the supervisor configuration specifies the udev filters and baud rate for the console connection.
