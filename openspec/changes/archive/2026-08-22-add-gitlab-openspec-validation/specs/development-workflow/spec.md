## MODIFIED Requirements

### Requirement: OpenSpec artifact validation in CI
GitHub validation workflows and GitLab release-tag pipelines SHALL run OpenSpec
artifact validation as a job independent from addon code validation. They SHALL
validate all tracked main specs and active changes without creating, applying,
syncing, or archiving artifacts.

#### Scenario: GitHub pull request contains valid artifacts
- **WHEN** the GitHub validation workflow runs for a pull request whose tracked OpenSpec artifacts are structurally valid
- **THEN** the OpenSpec validation job succeeds independently of the Lua validation job

#### Scenario: CI contains an invalid artifact
- **WHEN** a tracked OpenSpec spec or change fails full validation on GitHub or a GitLab release-tag pipeline
- **THEN** the platform's OpenSpec validation job fails its validation pipeline
- **AND** addon code checks remain a separately reported job

#### Scenario: Contributor does not use AI tooling
- **WHEN** a human-authored pull request does not modify OpenSpec artifacts
- **THEN** CI validates the existing tracked artifacts without inferring authorship or requiring agent workflow evidence

#### Scenario: GitLab publishes a backup release
- **WHEN** a valid release tag starts the GitLab publication pipeline
- **THEN** OpenSpec validation and Lua validation both succeed before the backup release job can start
