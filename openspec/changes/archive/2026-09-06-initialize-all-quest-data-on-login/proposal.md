## Why

Before checkpoint 1, EveryQuest used `LoadQuestData(group)` as both a raw
load-on-demand module loader and a mutating preparation path. Browsing zones could therefore
repeat history hydration, completed-flag synchronization, and chat output for
groups that only needed their static quest data made available.

Checkpoint 1 separated raw loading from one-time preparation and was merged
through PR #42 at `d36ff1e3446d32f61187794e73cc90aeab9ad62f`. Checkpoint 2
uses those boundaries to prepare all static groups on login/reload, then scan
the active quest log and report one concise startup summary.

## What Changes

- Add a load-only quest-data boundary that validates a group, loads the matching
  `EveryQuest_<Group>` load-on-demand addon when needed, returns structured
  failure reasons, and leaves failed attempts retryable.
- Add a one-time group preparation boundary that registers loaded static data in
  `QuestStore`, hydrates saved history, synchronizes completed flags without
  per-group chat output, and records structured statistics for later aggregation.
- Keep `EveryQuest:LoadQuestData(group)` as a compatibility adapter that returns
  the group table on success, returns `false` on failure, retries internally, and
  suppresses duplicate failure chat messages per group for the UI session.
- Prepare all groups in existing canonical search order through
  `PrepareQuestDataGroup`, aggregate its statistics and normalized failures,
  and keep startup failures retryable without consuming compatibility messages.
- After initial-zone selection, prepare all groups, scan the quest log quietly,
  print one summary, render the saved view, and mark initialization complete.
- Remove the manual per-module `collectgarbage("collect")` call from the normal
  load path instead of moving it elsewhere.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-runtime`: Add durable quest-data loading and preparation boundaries
  that preserve load-on-demand compatibility while avoiding repeated
  per-session history/status mutation.

## Impact

- Runtime modules: focused changes in `EveryQuest/Everyquest.lua` around
  load-on-demand quest-data loading, group preparation, history hydration, and
  completed-flag synchronization. `QuestStore` indexing behavior remains the
  registration target and is not replaced.
- Tests: focused Lua 5.1 regression coverage for the new boundaries plus the
  affected QuestStore/history/status test set.
- SavedVariables: no schema or migration changes. Existing
  `EveryQuestDBPC.char.history` data remains compatible.
- Data modules: no quest-data module changes and no generated static quest map.
- UI and startup: add `InitializeAllQuestData` and one startup summary; only
  the automatic scan uses `ScanQuestLog(false)`. Explicit reporting callers and
  XML/layout stay unchanged. Initial rendering reuses available data so a
  failed saved-zone group cannot produce an extra startup failure line.
- API audit, discovery, overlay, packaging, installation, release, and addon
  version workflows are outside this change.
- Evidence: local Lua regressions, `tools/verify-addon.sh`, OpenSpec
  validation, `git diff --check`, and full diff/function inspection are required
  before the local commit. Live TBC Anniversary behavior would require a
  separate human client run and is not proven by static checks.

## Non-goals

- Do not change quest lifecycle event order, Blizzard-owned UI behavior, zone
  browsing layout, API diagnostic surfaces, data provenance, or release
  workflows.
- Do not change SavedVariables schema or migrate existing saved history.
- Do not add dependencies, compatibility layers for non-Anniversary clients, or
  broad `QuestStore` rewrites.
