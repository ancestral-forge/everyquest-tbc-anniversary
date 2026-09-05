## Why

EveryQuest currently reuses static quest tables as mutable character-history
records and repeatedly scans loaded quest data and SavedVariables for quest IDs.
Those shortcuts are unsafe and too costly for a recursive Series feature, where
relationship metadata must remain immutable, optional providers must fail open,
and status reasons must be available without changing the existing UI.

## What Changes

- Introduce a `QuestStore` runtime module that indexes loaded static groups and
  character history by quest ID while retaining the existing load-on-demand
  fallback for groups that have not been indexed yet.
- Create all new character-history records from a whitelist of the existing
  flat metadata fields instead of assigning static quest tables into
  `EveryQuestDBPC.history`.
- Route existing lookup, history creation, hydration, and canonical-location
  behavior through the store without changing SavedVariables schema version 1.
- Introduce a UI-independent `QuestRelations` service that normalizes bundled
  and optional Questie chain data, preserves Questie's guarded fail-open and
  retry behavior, and provides an extensible result for future Series traversal.
- Introduce a structured `QuestState` result that separates stored progress
  from derived availability while keeping the legacy numeric-status adapter and
  current rendering behavior unchanged.
- Replace source-text extraction for the affected helpers with directly
  loadable Lua 5.1 module tests, including regressions for static/history
  non-aliasing, relation-field exclusion, indexes, provider failures, and legacy
  status precedence.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-runtime`: Add durable runtime boundaries for immutable static quest
  data, flat character-history records, indexed quest lookup, normalized
  relationship providers, and structured state with legacy display parity.

## Impact

- Runtime modules: new `EveryQuest/QuestStore.lua`,
  `EveryQuest/QuestRelations.lua`, and `EveryQuest/QuestState.lua`; focused
  adapters and registration hooks in `EveryQuest/Everyquest.lua` and load-order
  entries in `EveryQuest/EveryQuest.toc`.
- SavedVariables: `EveryQuestDBPC.schemaVersion` remains `1`; existing history
  records stay readable and retain their current flat fields. New records copy
  only the existing metadata whitelist, so relationship tables are never
  persisted by construction.
- Dependencies and data: Questie remains optional and no Questie data is copied.
  No bundled relationship database is populated in this foundation change;
  tests may inject small bundled fixtures through the provider boundary.
- Workflows and packaging: no CI, packaging, installation, backup, or release
  behavior changes are intended.
- Evidence: focused Lua 5.1 regressions, `tools/verify-addon.sh`, OpenSpec
  validation, and complete diff inspection are required locally. Visual status,
  lifecycle, disabled/faulty Questie, and no-regression behavior require a
  separate human run in the TBC Anniversary client; local checks and install
  parity do not prove live gameplay.

## Non-goals

- Do not add the Series browser, Why Unavailable UI, relation-data population,
  reputation/profession reasoning, breadcrumb warnings, or new filters.
- Do not split the rest of `Everyquest.lua`, rewrite `UpdateFrame`, XML, the
  27-row list, zone navigation, sorting, colors, options, or lifecycle events.
- Do not add SavedVariables schema version 2, an eager bulk migration, nested
  history objects, a generated global quest-ID map, Ace3, or another dependency.
- Do not change Blizzard-owned quest or reward UI behavior, target non-
  Anniversary clients, install into the WoW client, package, publish, merge,
  tag, or release as part of this change.
