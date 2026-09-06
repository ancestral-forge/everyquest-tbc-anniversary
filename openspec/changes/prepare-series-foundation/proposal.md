## Why

Before the first foundation checkpoint, EveryQuest reused static quest tables
as mutable character-history records and repeatedly scanned loaded quest data
and SavedVariables for quest IDs. PR #37 now creates fresh whitelisted history
records, preserving schema version 1 and preventing static/history aliasing.

The remaining repeated scans, canonical-location mutations, optional chain
provider, and numeric-only status resolver are still too fragile for recursive
Series traversal. In addition, the concurrently merged future-phase feature
introduced static-only presentation metadata (`p`); history rendering must join
that metadata from the static record without persisting it into character
history.

## What Changes

- Introduce a `QuestStore` runtime module that indexes loaded static groups and
  character history by quest ID while retaining the existing load-on-demand
  fallback for groups that have not been indexed yet.
- Keep all new character-history records owned by `QuestStore` and copied from
  the persisted flat metadata whitelist instead of assigning static quest
  tables into `EveryQuestDBPC.history`.
- Keep presentation-only and relationship metadata on static quest records and
  resolve it through the store when zone or history rows are rendered.
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
  only the persisted history whitelist. Relationship data and static-only
  presentation metadata such as phase `p` remain outside SavedVariables and are
  resolved from the static quest index when needed.
- Dependencies and data: Questie remains optional and no Questie data is copied.
  No bundled relationship database is populated in this foundation change;
  tests may inject small bundled fixtures through the provider boundary.
- Workflows and packaging: no CI, packaging, installation, backup, or release
  behavior changes are intended.
- Documentation: record each checkpoint's user-visible changes and bug fixes
  in `CHANGELOG.md` under `[Unreleased]` in the same PR, as required by
  `CONTRIBUTING.md`; purely internal refactors need no entry. This does not
  require a version bump or release action.
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
- Do not change Blizzard-owned quest or reward UI behavior or target non-
  Anniversary clients.
- Each review checkpoint may be installed, pushed, or merged only after its
  separate explicit authorization and evidence. Do not package, tag, publish,
  or release the addon as part of this foundation change.
