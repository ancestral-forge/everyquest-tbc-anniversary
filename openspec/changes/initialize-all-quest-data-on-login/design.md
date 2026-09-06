## Context

Checkpoint 1, merged through PR #42 at
`d36ff1e3446d32f61187794e73cc90aeab9ad62f`, split load-only module access
from one-time preparation and quiet compatibility browsing. Previously the
combined loader repeated hydration, completed sync, chat, and forced garbage
collection. `QuestStore` can still silently load and index data before the
preparation boundary is called. Checkpoint 2 adds startup orchestration without
changing those boundaries or canonical precedence.

## Goals / Non-Goals

**Goals:**

- Split load-only work from one-time group preparation while preserving existing
  `LoadQuestData(group)` callers.
- Keep preparation idempotent per UI session and preserve retry behavior after
  load failures.
- Aggregate preparation statistics and normalized failures into one startup
  summary after a quiet active quest-log scan.
- Remove normal-path manual per-module garbage collection.

**Non-Goals:**

- Do not change explicit `ScanQuestLog(true)` behavior, XML/layout,
  SavedVariables schema, quest-data modules, API audit/discovery/overlay
  behavior, packaging, installation, version, tag, or release workflow.

## Decisions

1. Keep the existing addon-name convention and loader helper.

   `EnsureQuestDataLoaded(group)` uses the current
   `EveryQuest_<group-with-spaces-replaced>` convention and the existing
   `loadQuestDataAddon` helper so missing, disabled, and generic load failures
   stay normalized the same way they are today. It returns the group data,
   normalized reason, and a `newlyLoaded` boolean. Rejected alternative:
   duplicate the addon loading checks in a second helper, which would make the
   failure taxonomy drift.

2. Track preparation in `sessionvars.preparedGroups`.

   `PrepareQuestDataGroup(group)` calls the load-only boundary, runs the
   existing hydration and completed-sync helpers that register the returned data
   in `QuestStore`, then marks the group prepared only after all of that work
   succeeds. Repeated calls return the same data plus a statistics table with
   `alreadyPrepared=true`. Rejected alternative: reuse
   `sessionvars.completedSyncGroups` as the preparation marker; that would miss
   hydration and make the compatibility case where `QuestStore` loaded first too
   ambiguous.

3. Let the compatibility adapter own user-facing failures.

   `LoadQuestData(group)` calls `PrepareQuestDataGroup(group)`, returns the
   group data on success and `false` on failure, and prints a failure message only
   once per group per UI session. The load-only and preparation boundaries stay
   silent. Rejected alternative: keep printing from the load-only boundary,
   which would reintroduce output when startup initialization probes all
   groups.

4. Keep `QuestStore`'s lookup loader load-only.

   The existing `QuestStore` loader remains a silent static lookup path. If it
   loads and registers a group first, a later `PrepareQuestDataGroup` call still
   performs hydration and completed sync because preparation state is independent
   from `QuestStore.indexedGroups`.

5. Prepare all groups in the existing canonical search order.

   `InitializeAllQuestData` iterates `canonicalQuestSearchGroups` directly and
   calls `PrepareQuestDataGroup`, never the compatibility adapter. Its fresh
   result contains numeric total/prepared/newly-loaded/already-prepared/failed
   group counts, sums of hydrated/checked/completed/added/changed statistics,
   and fresh `{group, reason}` failure entries. It attempts every group after
   ordinary load failures and logs details only through `Debug`. It neither
   marks failed groups prepared nor consumes `questDataLoadFailures`. Unexpected
   runtime exceptions retain the existing runtime error path.

6. Apply active state after completed flags and report once.

   After `SelectInitialZone`, `EveryQuestInit` runs `InitializeAllQuestData`,
   `ScanQuestLog(false)`, `PrintInitializationSummary`, and `List(savedView)`,
   then sets `sessionvars.initialized`. In Progress and Ready to Turn In states
   therefore override completed flags for active quests. The reporter receives
   the scan's returned counts, prints prepared/total quest data groups and active
   quests, and adds correctly pluralized failed-group/unmapped-quest warnings.
   A failed scan is identified as a warning, not a successful zero-quest scan.
   Checked/completed static-record counts are never presented as unique quests;
   history mutation totals remain structured diagnostics rather than chat counts.

7. Keep the initial view from retrying and reporting startup failures.

   A transient startup flag covers preparation, scan, and saved-view rendering.
   During that window `GetQuestZoneData` reads available data directly. This also
   covers frame updates flushed by the scan. After startup the existing
   `LoadQuestData` adapter resumes normal quiet reuse or retry with one detailed
   failure message. No changes to the adapter, layout, event ownership, or
   Blizzard UI are required.

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
