## ADDED Requirements

### Requirement: Quest data loading is separate from group preparation
EveryQuest SHALL expose a runtime boundary that can make one static quest-data
group available without also hydrating saved history, synchronizing completed
quest flags, producing ordinary chat output, or forcing garbage collection. A
failed load attempt MUST remain retryable.

#### Scenario: Static group loads without preparation side effects
- **WHEN** an available load-on-demand quest-data group is requested through the
  load-only boundary
- **THEN** the group data becomes available and is returned to the caller
- **AND** saved quest history is not hydrated during that load-only call
- **AND** completed quest flags are not synchronized during that load-only call
- **AND** no ordinary chat success or failure message is printed

#### Scenario: Existing loaded group is returned cheaply
- **WHEN** a static quest-data group is already available in the UI session
- **THEN** the load-only boundary returns the same group data without loading the
  addon again
- **AND** does not repeat runtime registration, hydration, completed-flag
  synchronization, chat output, or forced garbage collection

#### Scenario: Load failure remains retryable
- **WHEN** a static quest-data group cannot be loaded because its module is
  missing, disabled, fails to load, or publishes no data
- **THEN** the load-only boundary returns no group data and a distinguishable
  normalized failure reason
- **AND** a later request for the same group attempts loading again

### Requirement: Quest data groups are prepared once per UI session
EveryQuest SHALL provide a preparation boundary that makes a static quest-data
group available, registers it for indexed lookup, hydrates saved history, and
synchronizes completed quest flags at most once per successful group per UI
session.

#### Scenario: First preparation performs all group work
- **WHEN** an available quest-data group is prepared for the first time in a UI
  session
- **THEN** the group data is returned to the caller
- **AND** the loaded group is registered for indexed lookup
- **AND** saved history for that group is hydrated
- **AND** completed quest flags for that group are synchronized without
  per-group chat output
- **AND** structured preparation statistics report loading, hydration, checked,
  completed, added, and changed counts

#### Scenario: Repeated preparation is a no-op
- **WHEN** a quest-data group has already been prepared successfully in the UI
  session
- **THEN** later preparation calls return the same group data
- **AND** do not reload, re-register, rehydrate, or resynchronize the group
- **AND** structured preparation statistics identify the group as already
  prepared

#### Scenario: Earlier indexed load still receives preparation
- **WHEN** indexed lookup has already loaded and registered a group before the
  compatibility loading path is called
- **THEN** preparing that group still performs the one-time saved-history
  hydration and completed-flag synchronization
- **AND** the group is marked prepared only after those preparation steps
  succeed

### Requirement: Compatibility loading preserves failure behavior without success spam
Existing callers of the compatibility quest-data loading path SHALL continue to
receive the group table on success and `false` on failure. The compatibility
path SHALL preserve distinguishable user-facing failure meanings while
suppressing duplicate failure messages for the same group in one UI session and
never printing success messages.

#### Scenario: Successful compatibility load is quiet and repeatable
- **WHEN** an existing caller loads the same available quest-data group more than
  once through the compatibility path
- **THEN** each successful call returns the same group data table
- **AND** only the first call performs group preparation
- **AND** no ordinary chat success message is printed

#### Scenario: Duplicate failures are suppressed while retries continue
- **WHEN** loading a quest-data group fails repeatedly in the same UI session
- **THEN** at most one ordinary chat failure message is printed for that group
- **AND** each later call still retries the underlying load
- **AND** a later successful retry prepares the group normally

#### Scenario: Failure meanings remain distinguishable
- **WHEN** compatibility loading fails because a module is missing, disabled,
  fails generically, or publishes no group data
- **THEN** the ordinary chat failure message still identifies the matching
  failure meaning instead of collapsing every failure into a generic error

### Requirement: Future startup preparation can be summarized
EveryQuest SHALL be able to prepare all static quest-data groups during startup
and report one aggregated startup summary instead of per-group synchronization
messages, without changing SavedVariables schema or quest-data module contents.

#### Scenario: Startup prepares available groups
- **WHEN** the later startup checkpoint initializes all quest-data groups after
  normal addon setup
- **THEN** each available group is loaded and prepared through the same
  one-time preparation boundary
- **AND** missing, disabled, failed, or empty groups remain retryable

#### Scenario: Startup summary is aggregated
- **WHEN** the later startup checkpoint finishes attempting startup group
  preparation
- **THEN** the user-facing status output summarizes the aggregate result once
  instead of printing repetitive per-group load or synchronization messages
