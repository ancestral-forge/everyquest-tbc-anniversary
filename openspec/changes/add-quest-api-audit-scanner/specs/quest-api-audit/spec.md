## Purpose

Provide maintainers with a reproducible, read-only in-client audit of static EveryQuest quest IDs against the current TBC Anniversary quest API without treating API visibility as content availability.

## ADDED Requirements

### Requirement: Explicit maintainer invocation
EveryQuest SHALL start the quest API audit only from the documented maintainer slash command. It SHALL NOT run the audit at login, reload, addon initialization, options creation, frame display, or ordinary quest-log scanning, and SHALL NOT expose the command as a normal player feature or options-panel control.

#### Scenario: Normal addon startup
- **WHEN** EveryQuest initializes or the player opens its quest browser without entering the audit command
- **THEN** no static quest IDs are probed through the quest API

#### Scenario: Maintainer starts an audit
- **WHEN** the player enters `/everyquest api audit`
- **THEN** EveryQuest starts one quest API audit and reports that it has started

#### Scenario: General help remains player-focused
- **WHEN** the player enters `/everyquest help`
- **THEN** the regular usage text does not advertise the audit command

### Requirement: Complete read-only source collection
Before probing quest IDs, the audit SHALL load every shipped EveryQuest load-on-demand data module that is present and enabled, collect every positive numeric quest ID, de-duplicate the IDs, and use a stable ascending order. Collection SHALL NOT call a data-loading path that hydrates or synchronizes quest history.

#### Scenario: Duplicate quest records
- **WHEN** the same quest ID appears in more than one group or zone
- **THEN** the audit probes that quest ID once and counts it once in the total

#### Scenario: Stable audit order
- **WHEN** two audits collect the same set of quest IDs from differently ordered tables
- **THEN** both audits probe the same ascending sequence of quest IDs

#### Scenario: Unavailable data module
- **WHEN** any shipped quest-data module is missing, disabled, fails to load, or does not publish its expected data
- **THEN** the audit stops before API probing, identifies the affected module and reason, does not enable the module automatically, and does not replace the last complete report

#### Scenario: Existing character history
- **WHEN** collection loads previously unloaded quest-data modules
- **THEN** saved quest history, completion flags, selected zone, filters, and quest-browser state remain unchanged

### Requirement: Anniversary-native bounded probing
On Interface 20506 the audit SHALL probe each collected ID with `C_QuestLog.GetQuestInfo(questID)` in bounded batches distributed over multiple frame updates. It SHALL use Lua 5.1-compatible code and SHALL NOT depend on Retail-only asynchronous quest-data request APIs, external libraries, or network services.

#### Scenario: Large database audit
- **WHEN** an audit contains more quest IDs than one configured batch
- **THEN** EveryQuest yields between bounded batches, continues from the next ID, and exposes current progress

#### Scenario: API is unavailable
- **WHEN** `C_QuestLog.GetQuestInfo` is absent or not callable in the current client
- **THEN** the audit fails with an unsupported-API error and preserves the last complete report

### Requirement: Conservative result classification
The first probe pass SHALL classify non-empty titles as available, exceptions as probe errors, and missing or empty results as retry candidates. When retry candidates exist, the audit SHALL wait for at least ten seconds of frame-update elapsed time without issuing quest probes so the client cache can warm, then perform one second bounded pass over those candidates. Only IDs still missing or empty on the second pass SHALL be classified as unavailable. A probe error SHALL remain distinct from an unavailable result.

#### Scenario: Title available on first pass
- **WHEN** the API returns a non-empty title for an ID during the first pass
- **THEN** the audit counts the ID as available and does not retry it

#### Scenario: Title available on retry
- **WHEN** the first probe returns no usable title and the retry returns a non-empty title
- **THEN** the audit counts the ID as available and excludes it from the unavailable list

#### Scenario: Cold cache warm-up
- **WHEN** the first pass finishes with one or more retry candidates
- **THEN** EveryQuest issues no further quest probes for at least ten seconds of frame-update elapsed time, reports the warm-up state through status, remains cancellable, and then begins the single retry pass

#### Scenario: Title unavailable twice
- **WHEN** both probes return no usable title for an ID without raising an error
- **THEN** the completed report includes that ID in the unavailable list

#### Scenario: Probe raises an error
- **WHEN** probing an ID raises an error on either pass
- **THEN** the audit records the ID as a probe error rather than classifying it as unavailable

### Requirement: Observable lifecycle controls
EveryQuest SHALL support audit status, cancellation, and result clearing through `api audit status`, `api audit cancel`, and `api audit clear`. It SHALL prevent concurrent audit runs and SHALL report counts sufficient to distinguish collected, processed, available, retrying, unavailable, and errored IDs as applicable to the current state.

#### Scenario: Status during a run
- **WHEN** the player requests status while an audit is active
- **THEN** EveryQuest reports the current pass and processed count relative to that pass's total

#### Scenario: Status during cache warm-up
- **WHEN** the player requests status between the first and retry passes
- **THEN** EveryQuest reports the remaining bounded warm-up time and retry-candidate count

#### Scenario: Duplicate start request
- **WHEN** the player starts an audit while another audit is active
- **THEN** EveryQuest keeps the original run active and reports that an audit is already running

#### Scenario: Cancel active audit
- **WHEN** the player cancels an active audit
- **THEN** EveryQuest stops future probes, reports cancellation, and preserves the last complete report

#### Scenario: Clear stored result
- **WHEN** the player requests clear while no audit is active
- **THEN** EveryQuest removes only the stored quest API audit report and leaves all other character data unchanged

#### Scenario: Clear during active audit
- **WHEN** the player requests clear while an audit is active
- **THEN** EveryQuest rejects the clear request without changing the active run or stored complete report

### Requirement: Compact complete report persistence
After and only after a complete run, EveryQuest SHALL atomically replace the optional `EveryQuestDBPC.char.questApiAudit` report with a compact versioned record containing start and completion timestamps, addon version, client version, build, interface, locale, total/available/unavailable/error counts, the unavailable quest IDs, and probe-error IDs with concise reasons. Adding or removing this optional field SHALL NOT change the existing SavedVariables schema version or require migration.

#### Scenario: Successful completion
- **WHEN** both probe passes complete
- **THEN** the saved report metadata and counts describe that run and its unavailable IDs are stored in ascending order

#### Scenario: Cancelled or failed run
- **WHEN** an audit is cancelled or fails before completion
- **THEN** no partial report replaces the previously saved complete report

#### Scenario: Existing SavedVariables without a report
- **WHEN** a character loads SavedVariables created before this capability existed
- **THEN** EveryQuest initializes normally with quest history and settings intact and treats the audit report as absent

#### Scenario: Rollback to a version without the scanner
- **WHEN** the addon is replaced by a compatible earlier version that ignores the optional audit field
- **THEN** existing quest history and settings remain readable without migration

### Requirement: Audit output never mutates quest truth
The audit SHALL be evidence-only. It SHALL NOT add, remove, hide, reclassify, complete, abandon, or otherwise alter static quest records, character quest history, or displayed quest status based on whether a title is available from the API.

#### Scenario: Unavailable IDs are found
- **WHEN** a completed audit reports one or more unavailable IDs
- **THEN** the database, history, completion state, and quest-browser presentation remain unchanged

### Requirement: Maintainer interpretation and evidence boundaries
Maintainer documentation SHALL explain how to run, cancel, inspect, clear, flush, and locate the compact report. It SHALL state that title visibility is neither proof of realm phase availability nor proof that a quest is obtainable, and that unavailability is not sufficient evidence for deletion or hiding. Quest-data changes based on a report MUST be corroborated by provenance and live verification after the relevant content phase opens. Static tests and install parity SHALL NOT be reported as proof of live quest API behavior.

#### Scenario: Current phase contains future quest records
- **WHEN** an unavailable ID may belong to content that is not yet unlocked on realms
- **THEN** the documentation directs the maintainer to classify it as phase-pending and rerun the audit after the phase unlock or client-build change instead of changing the database

#### Scenario: Maintainer reviews a non-phase candidate
- **WHEN** a maintainer considers changing a quest record because of an audit result
- **THEN** the documented workflow requires an external provenance source and a live-client recheck before the data change is accepted

#### Scenario: Automated validation passes
- **WHEN** the OpenSpec validator and repository test gate pass without a live WoW run
- **THEN** the result is reported as static and automated evidence only

### Requirement: Licensing and provenance boundaries
The shipped implementation SHALL remain GPL-2.0-only and SHALL derive its audit input only from the repository's attributed quest records and its observations only from Blizzard's runtime API. It SHALL NOT embed copied third-party quest datasets in code, tests, or reports.

#### Scenario: Scanner is packaged
- **WHEN** the addon package includes the scanner
- **THEN** the existing license and quest-data attribution metadata remain intact and no new runtime dependency or copied quest dataset is introduced
