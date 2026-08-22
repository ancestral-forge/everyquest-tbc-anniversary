## ADDED Requirements

### Requirement: OpenSpec artifact validation in CI
The reusable project validation workflow SHALL run OpenSpec artifact validation
as a job independent from addon code validation. It SHALL validate all tracked
main specs and active changes without creating, applying, syncing, or archiving
artifacts.

#### Scenario: Pull request contains valid artifacts
- **WHEN** the validation workflow runs for a pull request whose tracked OpenSpec artifacts are structurally valid
- **THEN** the OpenSpec validation job succeeds independently of the Lua validation job

#### Scenario: Pull request contains an invalid artifact
- **WHEN** a tracked OpenSpec spec or change fails full validation
- **THEN** the OpenSpec validation job fails the reusable validation workflow
- **AND** addon code checks remain a separately reported job

#### Scenario: Contributor does not use AI tooling
- **WHEN** a human-authored pull request does not modify OpenSpec artifacts
- **THEN** CI validates the existing tracked artifacts without inferring authorship or requiring agent workflow evidence
