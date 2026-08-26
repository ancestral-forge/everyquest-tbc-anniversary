## Context

See `proposal.md` for motivation. EveryQuest records quest history from
Blizzard quest-log APIs and events, while its browsing UI is organized around
EveryQuest static quest buckets. Blizzard quest-log headers can describe the
currently displayed client category and are not always the canonical bucket for
a quest in EveryQuest data.

History is stored in `EveryQuestDBPC.history` by zone ID. This change does not
add a new SavedVariables schema field or version.

## Goals / Non-Goals

**Goals:**

- Prefer the EveryQuest static quest bucket for a known quest ID when saving
  quest-log derived history.
- Preserve existing completion state and metadata when a record moves from an
  incorrect bucket to the canonical bucket.
- Keep quest-log fallback metadata accurate for TBC Anniversary Lua 5.1 runtime
  paths.
- Keep Blizzard-owned quest UI behavior unchanged.

**Non-Goals:**

- No broad SavedVariables migration pass at login.
- No static quest data reclassification.
- No new external addon dependency or compatibility layer.
- No quest log UI redesign.

## Decisions

### Canonical static quest data wins for known quest IDs

When the quest ID exists in EveryQuest static data, the history save path uses
that static bucket instead of the active Blizzard quest-log category. This makes
the browsing history match EveryQuest data and prevents unrelated client headers,
such as Ironforge, from owning profession quests.

Alternative considered: continue trusting the quest-log header. This preserves
the current bug because Blizzard headers can represent how the quest is grouped
in the live log rather than EveryQuest's canonical browsing bucket.

### Use existing EveryQuest data modules as the lookup source

Canonical lookup uses already loaded quest data first, then the existing
load-on-demand EveryQuest data modules. No generated quest-ID map or third-party
database is introduced.

Alternative considered: add a standalone quest-ID-to-zone mapping table. That
would duplicate static data, create a second provenance surface, and increase
the chance of drift.

### Move misplaced records opportunistically

If a quest is saved under a conflicting bucket and the canonical bucket is
known, the save/hydration path writes the canonical entry, preserves the current
record data, and removes the conflicting entry. This is idempotent and does not
require a schema version bump because the SavedVariables shape is unchanged.

Alternative considered: run a global migration over all saved history at login.
That is broader than the bug requires and would touch records unrelated to the
current quest-log scan or selected quest.

### Interpret daily frequency by API source

The legacy `GetQuestLogTitle` fallback and native quest-log info API can expose
different daily-frequency value spaces. Daily detection is kept source-aware so
normal legacy quests are not misclassified as daily while native daily quests
remain supported.

Alternative considered: use one numeric comparison for both API paths. That is
fragile because matching numeric values do not carry the same meaning across the
legacy and native sources.

## Risks / Trade-offs

- Load-on-demand lookup may load an existing quest data module earlier than
  before -> lookup is limited to EveryQuest's own modules and falls back to the
  quest-log category if a module is unavailable.
- A stale misplaced record remains until that quest is saved or hydrated again
  -> this avoids a broad migration and keeps the change idempotent.
- Duplicate static quest IDs would make canonical ownership ambiguous -> the
  existing data model expects quest IDs to be unique; any duplicate data case is
  a separate data correction.
- Local checks do not prove live client behavior -> live confirmation must be
  reported separately from `tools/verify-addon.sh`.

## Migration Plan

1. Apply the runtime and regression-test changes in the separate task worktree.
2. Run focused Lua regressions and `tools/verify-addon.sh`.
3. If authorized, install the addon into the WoW client and confirm that
   Alliance Trauma no longer appears in Ironforge history after quest-log scan
   or hydration.
4. Rollback is the normal Git revert of the runtime change. No schema downgrade
   is required because no new SavedVariables field is introduced.
