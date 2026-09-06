## Purpose

Provide temporary maintainer diagnostics for quest titles unresolved by the client API, directly in the existing quest browser.

## ADDED Requirements

### Requirement: Session-only command toggle
`/everyquest api overlay` SHALL toggle diagnostics, report the new state, redraw the list, and default to off after reload. Disabling SHALL discard pending work and results. Re-enabling SHALL start a fresh check.

#### Scenario: Repeated command
- **WHEN** the command is invoked while enabled
- **THEN** all diagnostic markers disappear immediately and pending work stops

### Requirement: Bounded title checking
Only rendered quest IDs SHALL be checked while enabled. Duplicate IDs SHALL share a result. An initial empty API title SHALL trigger a cache-warming query and a delayed retry after 10 seconds. No marker SHALL appear while pending. A nonempty title SHALL suppress the marker. API errors or missing APIs SHALL NOT be interpreted as missing quest data.

#### Scenario: Cold cache
- **WHEN** an initially empty title becomes available during the wait
- **THEN** the retry leaves the quest unmarked

#### Scenario: Unresolved title
- **WHEN** the delayed retry still returns no title
- **THEN** the row shows `[?]`, meaning only that the API has not resolved its title

#### Scenario: New visible rows
- **WHEN** scrolling or changing zones renders new IDs while enabled
- **THEN** those IDs are checked without scanning unrelated data modules

#### Scenario: Probe failure
- **WHEN** an API call raises an error
- **THEN** the quest remains unmarked and a diagnostic message explains the error

### Requirement: Presentation and runtime compatibility
The marker SHALL appear immediately after the level/type prefix and before the phase label, as `[70][?][Phase 5] Title`. Existing status suffixes, colors, sorting, tooltips, clicks, static records and SavedVariables SHALL remain unchanged. The feature SHALL target Lua 5.1 and Interface 20506 and preserve licensing and provenance.

#### Scenario: Phase and status composition
- **WHEN** an unresolved Phase 5 quest has Failed status
- **THEN** it renders `[70][?][Phase 5] Title (Failed)` with the existing Failed color

### Requirement: Developer documentation and evidence
CONTRIBUTING.md SHALL describe the command, bounded checking and cache caveat. README and changelog SHALL omit this developer feature as requested. Automated validation SHALL be reported separately from live client verification.

#### Scenario: Local verification
- **WHEN** regression tests and the repository gate pass
- **THEN** live client verification remains pending until a human exercises the toggle and browsing path
