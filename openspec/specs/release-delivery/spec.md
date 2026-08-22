# Release Delivery Specification

## Purpose

Define deterministic versioning, packaging, publication, and backup behavior for
EveryQuest releases.

## Requirements

### Requirement: Version consistency
All `EveryQuest*` TOC files SHALL use Interface `20506` and the same release
version before packaging.

#### Scenario: Building a release
- **WHEN** `tools/package-release.sh v<version>` runs
- **THEN** the tag version matches the primary TOC, every module TOC, and a changelog heading

### Requirement: Deterministic addon-only package
GitHub and GitLab SHALL use `tools/package-release.sh` as the shared packaging
contract and SHALL package only the top-level `EveryQuest*` addon directories.

#### Scenario: Packaging the same tag twice
- **WHEN** the same source tag is packaged on either platform
- **THEN** the archive layout and checksum are reproducible
- **AND** repository-only documentation and workflow files are excluded

### Requirement: Canonical source and non-destructive backup
GitHub SHALL remain canonical, while GitLab synchronization SHALL preserve
backup refs and releases without force-pushing, pruning, or propagating source
deletions.

#### Scenario: Synchronizing GitHub to GitLab
- **WHEN** backup automation reconciles branches and tags
- **THEN** it adds or advances refs without deleting retained backup state

### Requirement: Publication state is explicit
A commit, pushed branch, merged pull request, tag, package artifact, and
published release SHALL be reported as separate delivery states.

#### Scenario: Version commit exists without a tag
- **WHEN** a release version is committed and pushed but no `v<version>` tag is published
- **THEN** the change is not reported as a release
