## Why

EveryQuest already lists quests from future TBC Anniversary content, but the live realm is currently in Phase 3. Players can therefore see valid Zul'Aman or Sunwell-era records without understanding why the quests are not obtainable yet.

## What Changes

- Add explicit phase metadata to reviewed quest records that belong to Phase 4 or Phase 5 content.
- Insert a plain `[Phase 4]` or `[Phase 5]` marker immediately after the existing `[level/type]` prefix and before the quest title while that phase's release-controlled display flag is enabled.
- Keep Phase 1-3 quests and quests without reviewed phase metadata unchanged.
- Use independent release flags for Phase 4 and Phase 5 so a patch can stop showing the Phase 4 marker after Zul'Aman opens without hiding the still-relevant Phase 5 marker.
- Add focused Lua regression coverage for phase metadata, title formatting, flag behavior, and interaction with existing status labels and colors.
- Do not add an overlay, tooltip, user setting, automatic phase detection, or API-derived phase inference.

## Capabilities

### New Capabilities

- `future-phase-labels`: Defines reviewed Phase 4/5 quest metadata and the release-controlled title marker shown for content that is not yet available.

### Modified Capabilities

None.

## Impact

- Addon runtime: `EveryQuest/Everyquest.lua` gains a small title-formatting boundary and release-controlled Phase 4/5 flags, while `EveryQuest/localization.lua` supplies the `Phase` label; existing status calculation and row colors remain unchanged.
- Quest data: reviewed records in the relevant `EveryQuest_*` data modules gain additive compact phase metadata. Existing quest IDs, names, levels, factions, types, ordering, attribution, and provenance remain intact.
- SavedVariables: `EveryQuestDB` and `EveryQuestDBPC` are unchanged; there is no migration or per-player option.
- Packaging and installation: no layout, dependency, backup, or release-process changes.
- Client behavior: only matching quest-list titles change, and only while the corresponding phase flag is enabled. Static tests and `tools/verify-addon.sh` are required; a human WoW client must separately verify the rendered text, clipping, colors, and disappearance after a flag is disabled.

## Non-goals

- Detect the active realm phase from `C_QuestLog.GetQuestInfo`, client version, calendar dates, server data, or network services.
- Classify all unavailable scanner results, remove or hide quests, or treat API title absence as proof of phase membership.
- Label Phase 1-3 content, seasons, legacy/retired quests, or unreviewed candidates.
- Add a player-facing toggle, tooltip, badge, overlay, new color, status value, SavedVariables field, compatibility layer, dependency, or broad quest-browser refactor.
