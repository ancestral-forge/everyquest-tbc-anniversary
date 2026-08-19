# Changelog

All notable changes to EveryQuest TBC Anniversary are documented in this file.

This changelog covers the Ancestral Forge continuation. Original EveryQuest
release-5 provenance is documented in `SVN_IMPORT_NOTES.md`.

## [Unreleased]

### Fixed

- Preserve the selected zone across reloads instead of resetting the browser to
  the player's current zone.
- Route the `Current Zone`, `Show Quest History`, and `Show Zone Quests` button
  labels through the existing locale table.

## [2026.3.3] - 2026-08-18

### Fixed

- Wait for the quest log to expose accepted quest categories before saving new
  quest history, keeping newly accepted quests synced to the correct zone.
- Keep the legacy zone dropdown under the selector while nudging long submenus
  upward just enough to keep their bottom edge on screen.
- Disable the `Current Zone` button when EveryQuest is already showing the
  player's current zone.

### Removed

- Remove the imported release-5 SVN changelog file from the addon tree.

## [2026.3.2] - 2026-08-16

### Added

- Add a `Current Zone` button that switches the EveryQuest browser to the
  player's current zone on demand, including city-name aliases such as
  `City of Ironforge` -> `Ironforge`.

### Changed

- Prefer the Anniversary `C_QuestLog` API for completed-quest state and
  supported quest-log calls.
- Remove unused legacy quest-counting code and empty XML script hooks.
- Remove old optional integration hooks for `LightHeaded` and `beql`.
- Remove the imported SVN `$Revision` runtime version fields.
- Use a strict Anniversary SavedVariables schema while migrating root-shaped
  legacy data.

### Fixed

- Avoid false abandoned quest timestamps when the Anniversary client emits
  `QUEST_REMOVED` during quest turn-in.
- Stop overriding Blizzard's `CloseSpecialWindows`; Esc closing now uses
  `UISpecialFrames`.
- Stop overriding Blizzard's quest abandon confirmation popup; quest abandon
  tracking now relies on `QUEST_REMOVED`.
- Stop overriding Blizzard's quest reward button; quest turn-in tracking now
  relies on the `QUEST_TURNED_IN` event.
- Coalesce `QUEST_LOG_UPDATE` quest-log scans and batch frame refreshes.
- Respect disabled quest data modules instead of enabling them during lazy load.
- Preserve existing quest history when migrating old root-shaped SavedVariables
  into the strict Anniversary schema.
- Handle the current Anniversary client's hybrid quest-log API by using the
  still-present quest-log globals for active quest-log entries when
  `C_QuestLog` entry methods are unavailable.
- Replace legacy global `gsub` and `sort` calls with namespaced Lua APIs to
  avoid login sync failures.

## [2026.3.1] - 2026-08-16

### Added

- WoW TBC Anniversary support for interface `20506`.
- Native addon initialization, saved-variable setup, event registration, and
  slash-command handling.
- Quest completion synchronization through `C_QuestLog`.
- Missing quest log entry reporting for quests not present in the bundled data.
- Project documentation, GPLv2 license text, and Ancestral Forge branding.

### Changed

- Modernized quest log rendering for the Anniversary client.
- Replaced legacy addon loading with `C_AddOns`.
- Reworked quest row rendering and texture clearing to avoid stale icons and
  unsafe texture state.
- Updated addon metadata to publish the current version under Ancestral Forge
  while preserving kandarz as the original author.

### Removed

- Obsolete Ace2-era runtime dependencies and compatibility shims.
- Legacy `embeds.xml` packaging path.
- Unused `modules.xml` import artifact.
- Misleading `/eq` alias and legacy commented Rock/LibRockConfig references.

### Fixed

- Startup hook ordering on the Anniversary client.
- Slash command registration.
- Frame initialization and quest list update errors.
- Completed quest flag sync and quest history updates.
