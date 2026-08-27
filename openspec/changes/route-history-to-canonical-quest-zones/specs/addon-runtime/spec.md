## ADDED Requirements

### Requirement: Canonical quest history buckets
EveryQuest SHALL store quest-log derived history under the canonical EveryQuest
static quest bucket when the quest ID can be resolved from loaded or loadable
quest data, instead of preserving a conflicting Blizzard quest-log header bucket.

#### Scenario: Quest logged under unrelated header
- **WHEN** a quest-log scan records a quest ID while the current quest-log
  category resolves to a different zone bucket
- **AND** EveryQuest static data resolves that quest ID to a canonical bucket
- **THEN** the history entry is saved under the canonical bucket
- **AND** the entry is removed from the conflicting category bucket without
  discarding status, completion count, title, level, or timestamp metadata

#### Scenario: Quest cannot be resolved statically
- **WHEN** a quest-log scan records a quest ID that cannot be resolved in
  EveryQuest static data
- **THEN** EveryQuest continues to use the best available quest-log category
  bucket
- **AND** existing history fields remain preserved

### Requirement: Quest-log metadata fidelity
EveryQuest SHALL preserve quest level from Blizzard quest-log APIs and SHALL mark
history as daily only when the active Blizzard API source explicitly identifies
the quest as daily.

#### Scenario: Legacy quest-log fallback captures level
- **WHEN** the native quest-log info API is unavailable and EveryQuest reads a
  normal quest from the legacy quest-log title API
- **THEN** the saved history preserves the quest level reported by the legacy API
- **AND** the quest is not marked daily unless the legacy daily frequency value is
  present

#### Scenario: Static or quest-log metadata proves non-daily
- **WHEN** existing history contains a daily marker for a quest
- **AND** current static data or quest-log metadata identifies the quest as
  non-daily
- **THEN** EveryQuest removes the stale daily marker without changing the stored
  completion state
