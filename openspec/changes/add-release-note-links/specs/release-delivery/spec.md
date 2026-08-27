## ADDED Requirements

### Requirement: Release notes include generated platform links
`tools/package-release.sh` SHALL append release and full-changelog links to
`dist/release-notes.md` without requiring those links in `CHANGELOG.md`.

#### Scenario: Packaging release notes
- **WHEN** `tools/package-release.sh v<version>` runs
- **THEN** `dist/release-notes.md` contains the current `CHANGELOG.md` version
  section
- **AND** `dist/release-notes.md` contains a generated `### Links` section
- **AND** `CHANGELOG.md` does not need release, compare, or pull request links
  for those generated links to exist

### Requirement: Platform upload labels use readable release names
CurseForge and Wago uploads SHALL use `EveryQuest TBC <version>` as their
platform-visible release label.

#### Scenario: Uploading CurseForge and Wago releases
- **WHEN** the release workflow publishes
  `dist/EveryQuest-TBC-Anniversary-<version>.zip`
- **THEN** the BigWigs `archive` path points at that ZIP
- **AND** the BigWigs `archive_name` is that ZIP filename
- **AND** the BigWigs `archive_label` is `EveryQuest TBC <version>`

### Requirement: WoWInterface receives BBCode changelogs
WoWInterface uploads SHALL receive a BBCode changelog converted from the
generated Markdown release notes.

#### Scenario: Uploading a WoWInterface release
- **WHEN** the release workflow publishes to WoWInterface
- **THEN** BigWigs converts `dist/release-notes.md` to a WoWInterface changelog
  format before upload
