## Context

See `proposal.md` for motivation. Current `LoadQuestData(group)` validates,
loads the `EveryQuest_<Group>` LOD addon, prints load/failure messages, calls
`collectgarbage("collect")`, registers the group in `QuestStore`, hydrates
saved history, synchronizes completed flags with per-group status output, and
returns the static group table. `QuestStore` also has an internal loader used by
indexed lookup; that loader can silently load and register static data before
the UI calls `LoadQuestData`.

## Goals / Non-Goals

**Goals:**

- Split load-only work from one-time group preparation while preserving existing
  `LoadQuestData(group)` callers.
- Keep preparation idempotent per UI session and preserve retry behavior after
  load failures.
- Return preparation statistics that can later feed an all-group startup
  summary.
- Remove normal-path manual per-module garbage collection.

**Non-Goals:**

- Do not add `InitializeAllQuestData`, an eager startup group loop, or startup
  summary output in checkpoint 1.
- Do not change `EveryQuestInit`, `ScanQuestLog(true)`, XML/layout,
  SavedVariables schema, quest-data modules, API audit/discovery/overlay
  behavior, packaging, installation, version, tag, or release workflow.

## Decisions

1. Keep the existing addon-name convention and loader helper.

   `EnsureQuestDataLoaded(group)` will use the current
   `EveryQuest_<group-with-spaces-replaced>` convention and the existing
   `loadQuestDataAddon` helper so missing, disabled, and generic load failures
   stay normalized the same way they are today. It returns the group data,
   normalized reason, and a `newlyLoaded` boolean. Rejected alternative:
   duplicate the addon loading checks in a second helper, which would make the
   failure taxonomy drift.

2. Track preparation in `sessionvars.preparedGroups`.

   `PrepareQuestDataGroup(group)` will call the load-only boundary, run the
   existing hydration and completed-sync helpers that register the returned data
   in `QuestStore`, then mark the group prepared only after all of that work
   succeeds. Repeated calls return the same data plus a statistics table with
   `alreadyPrepared=true`. Rejected alternative: reuse
   `sessionvars.completedSyncGroups` as the preparation marker; that would miss
   hydration and make the compatibility case where `QuestStore` loaded first too
   ambiguous.

3. Let the compatibility adapter own user-facing failures.

   `LoadQuestData(group)` will call `PrepareQuestDataGroup(group)`, return the
   group data on success and `false` on failure, and print a failure message only
   once per group per UI session. The load-only and preparation boundaries stay
   silent. Rejected alternative: keep printing from the load-only boundary,
   which would reintroduce output when future startup initialization probes all
   groups.

4. Keep `QuestStore`'s lookup loader load-only.

   The existing `QuestStore` loader remains a silent static lookup path. If it
   loads and registers a group first, a later `PrepareQuestDataGroup` call still
   performs hydration and completed sync because preparation state is independent
   from `QuestStore.indexedGroups`.

## Risks / Trade-offs

- Completion sync currently has its own `sessionvars.completedSyncGroups`
  idempotence. If another path marks a group synced before preparation, later
  preparation cannot force a second sync without broadening that contract.
  Existing behavior already treats that table as the per-session sync guard; the
  new preparation guard adds hydration idempotence without removing it.
- `HydrateQuestHistoryForGroup` and `SyncCompletedQuestFlagsForGroup` both keep
  their existing registration calls. This remains cheap because
  `QuestStore:RegisterGroup` is idempotent for the same table; changing those
  helpers would broaden this checkpoint.
- Local Lua tests can prove function behavior and static data non-mutation.
  They do not prove live TBC Anniversary client timing or chat-frame behavior;
  that remains a separate human runtime evidence layer.

## Migration Plan

No SavedVariables or data migration is required. Rollback is the normal code
revert because the change only adjusts runtime control flow and session-local
tables.
