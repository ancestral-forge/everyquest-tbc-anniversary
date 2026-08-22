## ADDED Requirements

### Requirement: GitLab jobs require explicit activation
Every job exposed by an admitted GitLab pipeline SHALL be blocking and manual,
so creating a pipeline alone does not consume runner time.

#### Scenario: Release tag creates manual jobs
- **WHEN** a version tag creates a GitLab pipeline
- **THEN** `lua`, `openspec`, and `publish-release` are exposed as manual jobs
- **AND** none starts until a maintainer explicitly activates it
- **AND** `publish-release` remains dependent on successful `lua` and `openspec` jobs

#### Scenario: Backup pipeline creates a manual sync job
- **WHEN** a schedule or web action creates a GitLab backup pipeline
- **THEN** `sync-github` is exposed as a manual job
- **AND** synchronization does not start until a maintainer explicitly activates it
