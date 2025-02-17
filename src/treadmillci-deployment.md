# The `treadmill.ci` Deployment

Under the umbrella of the [Tock project](https://tockos.org), we operate a
deployment of the Treadmill testbed on the `treadmill.ci` domain. Currently,
this deployment spans only a single site:

- [Princeton University Site 0](./treadmillci-deployment/sites/pton-srv0.md)

We operate the following central services for this deployment:

- The [Treadmill Switchboard](https://github.com/treadmill-tb/treadmill/tree/main/switchboard)
  at <https://swb.treadmill.ci/>
- Proxy servers:
  - `us-east-1.proxy.treadmill.ci` (on `tml-srv0.treadmill.ci`)

## Treadmill Switchboard

The Treadmill Switchboard at [https://swb.treadmill.ci/] runs on Fly.io. Its
service configuration is checked into the `treadmill` repository here:
https://github.com/treadmill-tb/treadmill/blob/main/switchboard/flyio/fly.toml

It uses a PostgreSQL cluster of three Fly machines for all persistent state. All
communication between users and supervisors run over the public HTTP and
WebSocket endpoints.

The Switchboard architecture currently does not allow running multiple
concurrent instances of the switchboard, although a rewrite of the supervisor
handling logic is planned that will enable this.

## Tailscale / Headscale Overlay Network

To facilitate communication between hosts and other Treadmill infrastructure,
all sites are linked together through a Tailscale mesh VPN, using the Headscale
coordination server running on `tml-srv0.treadmill.ci`. This VPN exclusively
routes IPv6 traffic.

Site servers are automatically assigned IPs in the range
`fd7a:115c:a1e0::/64`. Each site is further assigned a prefix in the network
`fd9d:773b:e6f8::/48`, which it announces via the Tailscale mesh VPN:

- [`pton-srv0`](./treadmillci-deployment/sites/pton-srv0.md):
  `fd9d:773b:e6f8:1::/64`

These prefixes are used to issue IPv6 addresses to hosts and allow IPv6 traffic
to be exchanged between hosts. [Proxy servers](#ssh-proxy-servers) also use
hosts' IPv6 addresses within the site subnets to make certain endpoints (such as
an SSH server) reachable to clients outside of the Treadmill testbed.

## Proxy Servers

To allow outside servers to reach certain endpoints running on Treadmill hosts
(such as an SSH server), we operate a set of proxy servers that expose
publically reachable endpoints mapped to endpoints on the internal IPv6 mesh
VPN. Currently, we operate the following proxy servers:

- `us-east-1.proxy.treadmill.ci`: located in Ashburn, VA

An internal endpoint exposed by a Treadmill host (such as
`[fd9d:773b:e6f8:cafe:ebdc:b6ff:fe7e:c37a]:22`) can then be made reachable
publically on one or more of the above proxy servers, such as
`us-east-1.proxy.treadmill.ci:22014` and `eu-west-1.proxy.treadmill.ci:45912`.

The mapping external to internal endpoints is currently static. In the future,
such mappings may be dynamically allocated according to the host's or the user's
location. The Switchboard provides an API endpoint to query the public SSH
(proxied) endpoints for a given job.

The proxy servers use an HAProxy reverse proxy to bridge public and private
endpoints.

## Costs

We host the Treamdill platform using various cloud providers, with fixed monthly
and usage-based charges. This table represents an estimate of the costs for
running the central Treadmill platform services, and does not include any
site-local resources:

| Service                 | Resource                                    | Monthly Cost | Yearly Cost |
|-------------------------|---------------------------------------------|--------------|-------------|
| `treadmill.ci`          | Domain Name                                 |              | US$18.49    |
| `swb.treadmill.ci`      | app (1x `shared-cpu-1x@256MB` machine)      | US$1.95      |             |
|                         | database (3x `shared-cpu-1x@256MB` machine) | US$6.30      |             |
| `tml-srv0.treadmill.ci` | Hetzner CPX21 (VM + bandwidth + IPv4)       | US$10.59     |             |
|-------------------------|---------------------------------------------|--------------|-------------|
| Total                   |                                             | US$18.84     | US$18.49    |
