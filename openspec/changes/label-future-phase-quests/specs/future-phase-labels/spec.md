## Purpose

Explain not-yet-open TBC Anniversary quest content in the EveryQuest list with a small, release-controlled phase marker while preserving existing quest status behavior.

## ADDED Requirements

### Requirement: Reviewed future-phase quest metadata
EveryQuest SHALL associate Phase 4 and Phase 5 with every shipped quest ID corroborated as gated to those phases. The reviewed set SHALL include all shipped Zul'Aman quests in Phase 4 and all shipped Shattered Sun Offensive, Isle of Quel'Danas, Magisters' Terrace, and Sunwell quests in Phase 5. Every occurrence of the same quest ID in the static database SHALL carry the same reviewed phase, and the addon SHALL leave Phase 1-3 and unreviewed quest records without phase metadata.

#### Scenario: Quest belongs to reviewed Phase 4 content
- **WHEN** a shipped quest record is corroborated as gated to Phase 4, including the Zul'Aman quest set
- **THEN** EveryQuest associates that quest ID with Phase 4

#### Scenario: Quest belongs to reviewed Phase 5 content
- **WHEN** a shipped quest record is corroborated as gated to Phase 5, including the Shattered Sun Offensive, Isle of Quel'Danas, Magisters' Terrace, or Sunwell quest set
- **THEN** EveryQuest associates that quest ID with Phase 5

#### Scenario: Duplicate quest record
- **WHEN** a reviewed Phase 4 or Phase 5 quest ID appears in more than one group or zone in the static database
- **THEN** every occurrence carries the same phase metadata

#### Scenario: Quest has no reviewed future phase
- **WHEN** a quest is from Phase 1-3 or its phase has not been corroborated
- **THEN** EveryQuest leaves the quest record unmarked and does not infer a phase from its ID, title, API visibility, client version, or current date

### Requirement: Independent release-controlled phase labels
EveryQuest SHALL provide independent release-controlled display flags for Phase 4 and Phase 5. While a phase's flag is enabled, a quest carrying that phase SHALL display a localized `[Phase N]` marker immediately after the existing `[level/type]` prefix and before its title. While that phase's flag is disabled, the marker SHALL be omitted without modifying the quest data or SavedVariables.

#### Scenario: Both future-phase flags are enabled during Phase 3
- **WHEN** the quest list renders reviewed Phase 4 and Phase 5 quests with both release flags enabled
- **THEN** their rendered text begins `[level/type][Phase 4] ` and `[level/type][Phase 5] ` respectively

#### Scenario: Zul'Aman opens
- **WHEN** a release disables only the Phase 4 display flag
- **THEN** Phase 4 quests render without a phase marker
- **AND** reviewed Phase 5 quests continue to render with `[Phase 5]` immediately before the title

#### Scenario: Phase label feature is retired
- **WHEN** both phase display flags are disabled
- **THEN** no quest title receives a phase marker
- **AND** existing quest records and player history remain unchanged

#### Scenario: Missing or unsupported phase metadata
- **WHEN** a quest has no phase metadata or has a value other than reviewed Phase 4 or Phase 5 metadata
- **THEN** EveryQuest renders the original `[level/type] title` text without a phase marker

### Requirement: Phase label is presentation-only
The phase marker SHALL NOT create a quest status, change the existing quest status, alter row color, add a badge or overlay, add tooltip content, hide a quest, or affect sorting and interaction. Existing Failed and Abandoned suffixes SHALL remain after the quest title.

#### Scenario: Future quest has no status
- **WHEN** an unrecorded future-phase quest is rendered
- **THEN** the row keeps the normal no-status color and behavior
- **AND** only `[Phase N]` is inserted between the existing level/type prefix and title

#### Scenario: Future quest has an existing status
- **WHEN** a future-phase quest is In Progress, Ready to Turn In, Completed, Unavailable, Abandoned, or Failed
- **THEN** EveryQuest preserves that status and its existing color
- **AND** the phase marker does not replace or emulate the status

#### Scenario: Future quest has a visible lifecycle suffix
- **WHEN** a future-phase quest is Abandoned or Failed
- **THEN** the row renders as `[level/type][Phase N] title (status)`

### Requirement: Anniversary runtime and data compatibility
The phase-label implementation SHALL remain compatible with TBC Anniversary Interface `20506` and Lua 5.1, preserve the existing GPL-2.0-only and quest-data attribution, add no runtime dependency, and make no change to `EveryQuestDB` or `EveryQuestDBPC`.

#### Scenario: Existing player data loads after the feature is added
- **WHEN** EveryQuest loads SavedVariables created by an earlier compatible release
- **THEN** quest history and profile settings load without migration
- **AND** phase labels are determined only by shipped metadata and release flags

#### Scenario: Automated validation passes without a client run
- **WHEN** focused Lua tests and `tools/verify-addon.sh` pass
- **THEN** the result is reported as static and automated evidence only
- **AND** rendered width, colors, and interaction remain pending until verified in a human-operated TBC Anniversary client
