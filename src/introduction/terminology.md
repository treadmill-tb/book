# Terminology

Treamill is a distributed system composed of multiple different
components. While individual deployments may differ and feature different sets
of components, this guide establishes the following general terminology:

#### <a name="treadmill-testbed"></a>The Treadmill testbed / the Treadmill system
Describes the overall Treadmill system, including all deployments and central
components. Excludes external actors, such as users or platforms that interact
with the Treadmill system.

#### <a name="dut"></a>Device Under Test / DUT
A chip, board, or other device that can be programmed, debugged, interacted
with, or otherwise controlled by users or the Treadmill testbed. Typically, DUTs
will be development boards that feature microcontrollers or SoCs, like a Nordic
Semiconductor nRF52840DK board.

#### <a name="site"></a>Site
A collection of DUTs and other shared, non-global infrastructure. A site has one
or more DUTs, companion software and hardware per DUT, and also includes central
software or hardware components shared among DUTs.

#### <a name="deployment"></a>Deployment
A physical deployment of a part of a Treadmill system, hosting one or more
DUTs. A deployment may consist of multiple Treadmill sites. A deployment is not
a concept used in the Treadmill system itself, but used in these and other
documents to denote parts of the Treadmill system that are in physically
distinct locations and/or under differing administrative control.

#### <a name="switchboard"></a>Switchboard
The single, centralized controller of a Treadmill testbed. A single Switchboard
instance coordinates and orchestrates workloads across multiple Treadmill
sites. It also implements central authentication and authorization mechanisms
and is the authoritative data source for many of these subsystems.

#### <a name="supervisor"></a>Supervisor
A supervisor is responsible for managing interactions with a DUT and runs on
site-local infrastructure. Examples are QEMU supervisors that manage virtual
machines connected to a DUT, or Netboot Supervisors that exercise control over
other *hosts* connected to a DUT. Supervisors connect to and are managed by the
Switchboard.

#### <a name="host"></a>Host
A device or environment exposed to users of the Treadmill system, connected to a
DUT. Hosts can be virtual machines, dedicated hardware hosts, containers, or
other environments. Hosts run software that is able to interact with and control
a DUT. Each Host is managed by a Supervisor.
