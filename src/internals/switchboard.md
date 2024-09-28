# The switchboard architecture

The switchboard can be roughly separated into components as follows:

- the `routes` module contains the functions that are called whenever the Axum HTTP server receives a request
- the `perms` module contains "permission" types which represent actions that can be carried out by the switchboard at
  the behest of the client
- the `auth` module carries out two functions:
    - firstly, it provides types that can be used to extract the API token from the `Authorization` HTTP header in
      incoming HTTP requests
    - secondly, it provides types that can be used to check whether a given API token (technically, a given _subject_)
      possesses some permission
- the `service` module is where the core of the switchboard is; it can be subdivided into four major components:
    - `service::socket_connection`, which handles interfacing with the WebSockets created when supervisors connect to
      the switchboard
    - `service::herd`, which aggregates those WebSocket connections and maintains ephemeral data about: which
      supervisors are and aren't connected, which are idle or aren't, etc.
    - `service::kanban`, which tracks all queued and dispatched jobs, and maintains ephemeral metadata about those jobs
    - and finally, `service` itself, which coordinates updates to the supervisor herd and the job kanban, handles
      timeouts and watchdogs, and maintains the database state

Everything else is either structural glue (i.e. `serve` and `config`, which handle the setup and configuration of the
Axum server instance), or SQL glue (i.e. the `sql` module, which contains functions and types for interfacing with the
database in a Rust-friendly manner).

```                                                                                                                      ┌───────────────────┐
                                                                                                                      ┌───────────────────┐
                                                                                                                      │ Postgres Database │
 ┌────────┐        ┌─────────────┐    ┌─────────────────┐        ┌────────────────┐   ┌───────────────────────┐       │                   │
 │ Client ├────────► Axum Server ├────► `routes` module ├────────► `perms` module ┼───► `auth` module         │       │ ┌─────────────┐   │
 └────────┘        └─────────────┘    └─────────────────┘        └────────┬───────┘   │                       ┼───────┼─► permissions │   │
                             ▲─┐         ▲─┐                              │           │    Token extractor    │       │ │ tables      │   │
                             │ │         │ │                              │           │                       │       │ └─────────────┘   │
                             │ │         │ │                              │           │    Permissions lookup │       │                   │
                             │ └─────────┘ │                              │           └───────────────────────┘       │                   │
                             │             │                              │                                           │                   │
                             │             │                              │                                           │                   │
                             │             │                     ┌────────▼─────────┐                                 │ ┌────────────┐    │
                             │             │   ┌───────────┐     │ Service instance ┼─────────────────────────────────┼─► job &      │    │
 ┌─────────────┐             │             └───► Websocket ┼──┐  └──┬────────────┬──┘                                 │ │ supervisor │    │
 │ Supervisor  ┼─────────────┘                 │ handler   │  │     │            │                                    │ │ tables     │    │
 └─────────────┘                               └───────────┘  │     │            │                                    │ └────────────┘    │
                                                              │     │            │                                    │                   │
                                                        ┌─────▼─────▼───┐      ┌─▼───────────────┐                    └───────────────────┘
                                                        │ Herd instance │      │ Kanban instance │                                         
                                                        └───────────────┘      └─────────────────┘                                         
```

Figure 1: Architectural diagram of the switchboard

# The `Service`

... is the most complex part of the switchboard.

Its primary tasks are as follows:

1. track which supervisors are and aren't connected, and what those supervisors are working on.
2. track queued and dispatched jobs while: (a) checking for timeouts, (b) dispatching queued jobs when possible,
   (c) aggregating job-related messages that come in from the supervisor, (d) being able to cancel jobs, whether due to
   user instruction or timeout
3. transparently and gracefully handle supervisor and switchboard disconnections and restarts

# Supervisor state

```
                            supervisor disconnects                              
                          ┌─────────────────►──────────────────────────┐        
           supervisor disconnects                                      │        
         ┌───────────►─── │ ──────────────────────────┐                │        
         │                │                           │                │        
┌────────┼────────────────┼───────┐          ┌────────┼────────────────┼───────┐
│ Connected               │       │          │ Disconnected            │       │
│        ▲ job dispatches ▲       │          │        │                │       │
│        │┌─────◄────────┐│       │          │        │                │       │
│        │▼              ││       │          │        ▼▼               ▼       │
│       Busy            Idle      │          │      (Busy)          (Idle)     │
│        ▲│              ▲▲       │          │        ││              ▲│       │
│        │└────────►─────┘│       │          │        │└────────►─────┘│       │
│        │ job terminates │       │          │        ▼ job terminates │       │
│        │                │       │          │        │                │       │
└────────┼────────────────┼───────┘          └────────┼────────────────┼───────┘
         └─────────────── │ ───────────◄──────────────┤                │        
                          │ supervisor connects with  │                │        
                          │ correct job ID            │                │        
                          │                           │                │        
                          ▲────────────◄──────────────┘                │        
                          │ supervisor connects with                   │        
                          │ no/wrong job ID                            │        
                          │                                            │        
                          └────────────◄───────────────────────────────┘        
                            supervisor connects                                 
```

Figure 2: Supervisor state machine

There are two aspects of supervisor state:

- whether the supervisor is connected or not
- whether the supervisor has a job dispatched or not

**IMPORTANT NOTE**: The `Herd` does not distinguish between `Disconnected (Busy)` and `Disconnected (Idle)`.
However, the `Service`, when checking supervisor status _at the user's behest_, will perform additional queries to the
database to distinguish the two for purely informational reasons.
This simplifies the switchboard since the database becomes the sole source of truth for disconnected supervisors.

In order to support dispatching jobs, the switchboard has an internal notion of _reservations_, which are in effect
exclusive temporary 'borrowings' of a supervisor _connection_. Note that the abstraction of reservation _only_ exists at
this level; a reservation will not persist across supervisor reconnection.
