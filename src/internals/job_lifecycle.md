# Job Lifecycle

Treadmill jobs represent units of work schedulable on a supervisor. Each job is
eligible to run on a set of supervisors, limited by a set of *tag filter
expressions* governed by the job request, and the permissions of the user who
scheduled the job.

From the point of their creation up to their successful completion or failure,
jobs go through a set of *state changes*. A job's state is composed of two
components: its *execution state*, and its *exit status*.

A job's *execution state* describes the *current* state of the schedulable unit
of work and is controlled by the Switchboard (e.g., by assigning a job on a
particular supervisor), and the Supervisor (e.g., by starting or terminating a
Virtual Machine). A job may not necessarily transition through all defined
execution states; states may be arbitrarily skipped. All jobs must eventually
end up in the `Terminated` state. **Only some transitions between different
execution states are legal.** When attempting to take an illegal transition
towards another execution state, the Switchboard may ignore this transition, or
attempt to terminate the given job. A job that reached the `Terminated` state
must not transition to other states; **a `Terminated` execution state is
final**.

The *exit status* is controlled by the supervisor and describes the user-visible
state that the job assumes once it reaches the `Terminated` execution state. A
job's exit status may be set multiple times, but must not change once the job's
execution state reaches `Terminated`. The execution state can be used to
communicate whether the Treadmill system was able to successfully schedule the
job, whether there were any Treadmill system-internal errors that prevented its
successful execution, and whether the user-defined job workload reported a
success or error result. **Only some transitions between different exit statuses
are legal.** When attempting to take an illegal transition towards another exit
status, the previous exit status remains valid.

We describe these two components as Rust enums below.

## Execution State

```rust
enum ExecutionState {
    /// A job object has been created, but it has not been assigned to a
    /// supervisor yet.
    ///
    /// This is the starting state for newly created jobs.
    Queued,

    /// A job object has been assigned to a particular supervisor.
    Scheduled,

    /// A job is scheduled on a particular supervisor and is starting or
    /// restarting.
    ///
    /// An `Initializing` job may itself report different sub-states which
    /// indicate progress while starting the job. These are for informational
    /// purposes only. Not all restarts of a job's host will re-enter the
    /// `Starting` state.
    Initializing,

    /// The job is fully started and ready to execute user-defined workloads.
    ///
    /// A `Ready` job may itself report different sub-states which indicate
    /// progress or certain events, such as a soft-reboot of the job's host.
    /// These are for informational purposes only.
    Ready,

    /// The job has been requested to terminate.
    ///
    /// A `Terminating` job may itself report different sub-states which
    /// indicate progress of requesting a host shutdown, deallocating of
    /// resources, and other events.
    Terminating,

    /// The job has been terminated.
    ///
    /// This state is final. The job must not transition into any other
    /// execution states, and its exit status must not change.
    Terminated,
}
```

A transition into `Queued` may only be performed by the Switchboard. A
transition into the `Initializing`, `Ready`, and `Terminating` state may only be
performed by a Supervisor. The `Terminated` state can be reached by either
- an explicit state transition initiated by a Supervisor, or
- the Switchboard, when it observes that a Supervisor is no longer reporting to
  be executing a job that was once `Scheduled` on it. In this case, the exit
  status shall be set to `SupervisorJobDropped`. This may happen in the case of
  Supervisor failures or restarts.

Valid Transitions:
| To → <br> From ↓ | Q'd | Sched | Init | Ready | Term-ing | Term'd |
|------------------|-----|-------|------|-------|----------|--------|
| Queued           | -   | ✔     | ✔    | ✔     | ✔        | ✔      |
| Scheduled        | ✘   | -     | ✔    | ✔     | ✔        | ✔      |
| Initializing     | ✘   | ✘     | -    | ✔     | ✔        | ✔      |
| Ready            | ✘   | ✘     | ✔    | -     | ✔        | ✔      |
| Terminating      | ✘   | ✘     | ✘    | ✘     | -        | ✔      |
| Terminated       | ✘   | ✘     | ✘    | ✘     | ✘        | -      |

## Exit Status

```rust
enum ExitStatus {
    /// There are no supervisors registered that this job can be scheduled on,
    /// considering the job's tag filter expression and the scheduling user's
    /// permissions.
    ///
    /// Jobs may enter this state either immediately, at the time of scheduling
    /// a job, or when no eligible supervisor is found within a timeout.
    ///
    /// **This exit status is final.** No subsequently reported exit status may
    /// override this status.
    SupervisorMatchError,

    /// There were eligible supervisors registered with the Switchboard, but
    /// the job could not be scheduled on one of them within a given timeout.
    ///
    /// **This exit status is final.** No subsequently reported exit status may
    /// override this status.
    QueueTimeout,

    /// An internal error occurred while scheduling or running this job on the
    /// supervisor. This state may optionally contain a message that contains
    /// further information on the error.
    ///
    /// This exit status may be set by both the Switchboard (e.g., when there is
    /// an error communicating with the Supervisor), or by the Supervisor.
    ///
    /// **This exit status is final.** No subsequently reported exit status may
    /// override this status.
    InternalSupervisorError,

    /// The Supervisor reports that the host failed to start.
    ///
    /// This may be due to an error in fetching the requested image, a resource
    /// that vanished (e.g., when trying to continue a previous job), failure
    /// to allocate sufficient resources, etc.
    ///
    /// **This exit status is final.** No subsequently reported exit status may
    /// override this status.
    SupervisorHostStartError,

    /// The job was canceled by a user.
    ///
    /// **This exit status is final.** No subsequently reported exit status may
    /// override this status.
    JobCanceled,

    /// The host itself reports that the user-defined workload executed
    /// successfully.
    ///
    /// This status may be reported through the Puppet process executing within
    /// the host, and may optionally contain additional user-supplied
    /// information.
    JobUserSuccess,

    /// The host itself reports that the user-defined workload failed with an
    /// error.
    ///
    /// This status may be reported through the Puppet process executing within
    /// the host, and may optionally contain additional user-supplied
    /// information.
    JobUserError,

    /// The job vanished from its supervisor, without reaching the
    /// `Terminated` execution state first.
    ///
    /// This may be due to a supervisor crash or restart. This exit status is
    /// can only be set by the Switchboard. **This exit status is final.** No
    /// subsequently reported exit status may override this status.
    SupervisorJobDropped,
}
```

Valid Transitions:
| To → <br> From ↓         | SupMF | QTime | IntSupE | SupHSE | JobC | JobUS | JobUE | SupJDrop |
|--------------------------|-------|-------|---------|--------|------|-------|-------|----------|
| SupervisorMatchError     | -     | ✘     | ✘       | ✘      | ✘    | ✘     | ✘     | ✘        |
| QueueTimeout             | ✘     | -     | ✘       | ✘      | ✘    | ✘     | ✘     | ✘        |
| InternalSupervisorError  | ✘     | ✘     | -       | ✘      | ✘    | ✘     | ✘     | ✘        |
| SupervisorHostStartError | ✘     | ✘     | ✘       | -      | ✘    | ✘     | ✘     | ✘        |
| JobCanceled              | ✘     | ✘     | ✘       | ✘      | -    | ✘     | ✘     | ✘        |
| JobUserSuccess           | ✘     | ✘     | ✔       | ✔      | ✔    | -     | ✔     | ✔        |
| JobUserError             | ✘     | ✘     | ✔       | ✔      | ✔    | ✔     | -     | ✔        |
| SupervisorJobDropped     | ✘     | ✘     | ✘       | ✘      | ✘    | ✘     | ✘     | -        |

We further impose the following restricts on transitions of exit statuses
depending on the current execution state (**note the flipped rows & columns for
readability**):
| In Execution State → <br> To Exit Status ↓ | Q'd | Sched | Init | Ready | Term-ing | Term'd |
|--------------------------------------------|-----|-------|------|-------|----------|--------|
| SupervisorMatchError                       | ✔   | ✘     | ✘    | ✘     | ✘        | ✘      |
| QueueTimeout                               | ✔   | ✘     | ✘    | ✘     | ✘        | ✘      |
| InternalSupervisorError                    | ✘   | ✔     | ✔    | ✔     | ✔        | ✘      |
| SupervisorHostStartError                   | ✘   | ✔     | ✔    | ✔     | ✔        | ✘      |
| JobCanceled                                | ✘   | ✔     | ✔    | ✔     | ✔        | ✘      |
| JobUserSuccess                             | ✘   | ✔     | ✔    | ✔     | ✔        | ✘      |
| JobUserError                               | ✘   | ✔     | ✔    | ✔     | ✔        | ✘      |
| SupervisorJobDropped                       | ✘   | ✔     | ✔    | ✔     | ✔        | ✘      |
