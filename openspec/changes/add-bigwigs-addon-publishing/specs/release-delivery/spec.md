## ADDED Requirements

### Requirement: Configured addon platforms reuse the release package
CurseForge, Wago, and WoWInterface publishing SHALL reuse the same version,
archive, and release changelog that are generated for the GitHub Release.

#### Scenario: Tagged release publishes configured platforms
- **WHEN** a `v<TOC version>` tag runs the release workflow
- **THEN** `tools/package-release.sh` creates
  `dist/EveryQuest-TBC-Anniversary-<version>.zip`
- **AND** `tools/package-release.sh` creates `dist/release-notes.md` from the
  matching `CHANGELOG.md` version section
- **AND** the GitHub Release uses that archive and `dist/release-notes.md`
- **AND** each configured external platform upload uses that same archive and
  `dist/release-notes.md`

#### Scenario: External platform configuration is missing
- **WHEN** a platform project ID and API token are both empty
- **THEN** that platform upload is skipped without changing GitHub Release
  publication

#### Scenario: External platform configuration is partial
- **WHEN** only one of a platform project ID or API token is configured
- **THEN** the release workflow fails before attempting that platform upload
