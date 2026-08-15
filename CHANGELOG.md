# Changelog

All notable changes to EveryQuest TBC Anniversary are documented in this file.

This changelog covers the Ancestral Forge continuation. The original EveryQuest
SVN changelog is preserved separately in
`EveryQuest/Changelog-EveryQuest-release-5.txt`.

## [2026.3.1] - Unreleased

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
