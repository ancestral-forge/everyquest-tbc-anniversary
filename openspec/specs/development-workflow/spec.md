# Development Workflow Specification

## Purpose

Define a lightweight human contribution path alongside stricter AI planning,
isolation, validation, and evidence rules for EveryQuest changes.

## Requirements

### Requirement: Isolated implementation state
AI-agent implementation SHALL start from a recorded repository state and SHALL
preserve unrelated work by using a clean, separate worktree on a task-named
branch based on the current canonical main branch. Human contributors SHALL NOT
be required to use a separate worktree.

#### Scenario: AI agent starts an implementation task
- **WHEN** an AI agent is authorized to modify the repository
- **THEN** it records the branch, SHA, worktree list, and dirty state before editing
- **AND** it performs implementation outside the primary checkout on a task-named branch

#### Scenario: Human uses a normal clone
- **WHEN** a human contributor starts from a clean task branch in a normal repository clone
- **THEN** the contribution workflow accepts that branch without requiring another worktree

### Requirement: Lightweight human contribution path
Human contributors SHALL be able to propose and deliver a focused change using
a normal branch, the project validation gate or CI, and a pull request without
installing AI or OpenSpec tooling.

#### Scenario: Human submits an ordinary contribution
- **WHEN** a contributor prepares a focused bug fix, small feature, documentation change, localization change, or quest-data correction
- **THEN** the contributor can use a normal branch and pull request
- **AND** a separate worktree, AI skill, and OpenSpec command are not submission requirements

#### Scenario: Contributor cannot run the gate locally
- **WHEN** a contributor does not have the local Lua or XML toolchain
- **THEN** the contributor can submit the pull request and rely on the required CI gate
- **AND** the pull request does not claim local validation that did not occur

### Requirement: Spec-first material changes
The project SHALL capture high-risk or durable contract changes in OpenSpec
before merge. Human contributors SHALL NOT be required to install or invoke
OpenSpec to submit a change; maintainers can derive the artifacts from an issue
or pull-request discussion.

High-risk or durable contract changes include SavedVariables schema or
migration, quest lifecycle or Blizzard UI ownership, architecture or dependency
boundaries, CI and validation contracts, packaging, installation, backup, and
release behavior. Ordinary focused bug fixes, small features, documentation,
localization, and reviewable quest-data corrections do not require OpenSpec
unless they expose an unresolved product or architectural decision.

#### Scenario: AI agent changes a durable contract
- **WHEN** an AI request changes a high-risk or durable contract
- **THEN** the agent creates an OpenSpec change defining scope, non-goals, requirements, design decisions, tasks, and required evidence before implementation

#### Scenario: Human proposes a high-risk change
- **WHEN** a human contributor describes a high-risk change through an issue or pull request without OpenSpec artifacts
- **THEN** a maintainer can review the proposal and capture the required OpenSpec artifacts before merge
- **AND** the contribution is not rejected merely for lacking AI tooling

#### Scenario: Ordinary focused change
- **WHEN** a focused change leaves durable contracts unchanged and has clear acceptance criteria
- **THEN** an issue or pull-request description is sufficient planning evidence

#### Scenario: Request is read-only or mechanical
- **WHEN** work is limited to investigation or a typo with no changed behavior or acceptance criteria
- **THEN** no new OpenSpec change is required

### Requirement: Mandatory local verification gate
Every implementation SHALL pass `tools/verify-addon.sh` before it is described
as locally validated.

#### Scenario: Implementation is ready for review
- **WHEN** source edits are complete
- **THEN** the gate checks repository whitespace, Luacheck, Lua 5.1 compatibility, XML, TOC consistency and references, and checked-in regression tests
- **AND** any failing check prevents a locally validated claim

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

### Requirement: Evidence is not conflated
Reports and OpenSpec tasks SHALL distinguish source inspection, static checks,
automated tests, package verification, installed-file parity, live-client
behavior, Git delivery, remote CI, merge, tag, and release state.

#### Scenario: No live client test occurred
- **WHEN** static checks and install parity pass without exercising the WoW client
- **THEN** live-client verification remains explicitly pending
- **AND** no gameplay or rendered-UI success is claimed

### Requirement: Evidence-backed task completion
An evidence-dependent OpenSpec task SHALL remain unchecked until its exact
command or runtime path succeeds.

#### Scenario: Required environment is unavailable
- **WHEN** a required package, client, credential, CI run, or external service cannot be exercised
- **THEN** the task remains incomplete and the blocker is reported
- **AND** the agent does not substitute intention, inference, or a weaker evidence layer
