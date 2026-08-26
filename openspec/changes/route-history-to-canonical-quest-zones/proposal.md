## Why

Quest-log history can be saved under the active Blizzard quest-log header instead
of the EveryQuest canonical quest bucket. This makes quests such as Alliance
Trauma appear in Ironforge history even though the quest belongs to the First Aid
profession data and sends the player to Theramore in Dustwallow Marsh.

## What Changes

- Route quest-log scan history to the canonical EveryQuest static quest bucket
  when the quest ID can be resolved in loaded or loadable quest data.
- Preserve existing history fields while moving a misplaced quest record out of
  the quest-log header bucket.
- Keep the legacy `GetQuestLogTitle` fallback level value and interpret legacy
  daily frequency separately from native `C_QuestLog` frequency values.
- Clear stale daily markers when static data or current quest-log metadata proves
  that a quest is not daily.
- Add focused Lua regressions for the canonical routing, metadata hydration, and
  quest-log fallback behavior.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-runtime`: Quest-log derived history must use canonical EveryQuest quest
  buckets when the quest ID is known, while preserving SavedVariables
  compatibility.

## Non-goals

- Do not reclassify static quest data. Alliance Trauma remains a First Aid quest
  unless a separate data correction changes the database.
- Do not add Questie or other addon dependencies.
- Do not redesign the quest log UI, zone menu, packaging workflow, install
  workflow, or release workflow.
- Do not perform broad SavedVariables migrations beyond moving the affected
  quest history record during normal save/hydration.

## Impact

- Addon runtime: `EveryQuest/Everyquest.lua` history save, static quest lookup,
  quest-log scan, and metadata hydration paths.
- SavedVariables: `EveryQuestDBPC.history` may move a quest record from a
  Blizzard header zone ID to the canonical EveryQuest zone ID during normal
  history save or hydration, preserving status and metadata where possible.
- Data modules: static quest lookup may load existing EveryQuest data modules on
  demand for canonical lookup; no static data files are changed.
- Tests: Lua regression coverage under `tools/`.
- Documentation: release-dated entry in `CHANGELOG.md`.
- Evidence: local static/test evidence uses `tools/verify-addon.sh`; install
  parity and live WoW behavior require a human client run and are tracked
  separately from local verification.
