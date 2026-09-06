# Addon Runtime Specification

## Purpose

Capture the durable runtime boundaries that every EveryQuest change must
preserve unless a reviewed OpenSpec change explicitly revises them.

## Requirements

### Requirement: TBC Anniversary runtime target
The addon SHALL target WoW TBC Anniversary Interface `20506` and Lua 5.1.

#### Scenario: Adding or changing runtime code
- **WHEN** Lua, XML, or TOC files change
- **THEN** the result remains valid for Interface 20506 and Lua 5.1
- **AND** older-client compatibility branches are not added without an explicit scope change

### Requirement: Blizzard-owned quest UI
EveryQuest SHALL observe and record quest state without replacing Blizzard-owned
secure reward or quest-completion UI handlers.

#### Scenario: Recording quest completion
- **WHEN** the client emits quest lifecycle events
- **THEN** EveryQuest updates its history from supported events and APIs
- **AND** Blizzard remains responsible for reward choice and quest completion controls

### Requirement: SavedVariables compatibility
Changes SHALL preserve existing per-account and per-character quest history
unless the change specifies and tests a versioned migration.

#### Scenario: Stored schema changes
- **WHEN** a change alters the shape or meaning of `EveryQuestDB` or `EveryQuestDBPC`
- **THEN** the OpenSpec design defines compatibility, migration, idempotence, and rollback behavior
- **AND** focused regression coverage protects existing history fields

### Requirement: Attribution and provenance
The maintained addon SHALL preserve GPL-2.0-only licensing, original EveryQuest
attribution, and reviewable provenance for imported quest data.

#### Scenario: Adding code or quest data
- **WHEN** a change introduces third-party code, assets, or generated quest records
- **THEN** its source and compatible license are documented before distribution

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

### Requirement: Startup preparation is summarized
EveryQuest SHALL be able to prepare all static quest-data groups during startup
and report one aggregated startup summary instead of per-group synchronization
messages, without changing SavedVariables schema or quest-data module contents.

#### Scenario: Startup prepares available groups
- **WHEN** login or reload initializes all quest-data groups after
  normal addon setup
- **THEN** each available group is loaded and prepared through the same
  one-time preparation boundary
- **AND** missing, disabled, failed, or empty groups remain retryable

#### Scenario: Startup summary is aggregated
- **WHEN** startup finishes all group attempts and the quiet active quest-log scan
- **THEN** the user-facing status output summarizes the aggregate result once
  instead of printing repetitive per-group load or synchronization messages

#### Scenario: Startup follows canonical precedence and isolates failures
- **WHEN** startup prepares static quest-data groups
- **THEN** each canonical group is attempted in the existing canonical order
- **AND** a failed group does not prevent later attempts
- **AND** returned statistics and normalized failures do not expose internal tables
- **AND** startup does not populate compatibility failure-message deduplication

#### Scenario: Active quest state follows completed synchronization
- **WHEN** initial-zone selection finishes on login or reload
- **THEN** all group preparation attempts precede one `ScanQuestLog(false)` call
- **AND** active In Progress and Ready to Turn In states are applied afterward
- **AND** one summary precedes saved-view rendering and the initialized marker
- **AND** explicit callers of `ScanQuestLog(true)` retain detailed reporting

#### Scenario: Startup warnings remain concise
- **WHEN** groups fail or active quests cannot be mapped
- **THEN** the single summary includes correctly pluralized failure/unmapped counts
- **AND** no ordinary per-group or individual unmapped messages are printed
- **AND** checked/completed static-record totals are not presented as unique quests
- **AND** rendering a failed saved-zone group does not emit another failure line
- **AND** later user-driven zone browsing can retry and report its normal failure
