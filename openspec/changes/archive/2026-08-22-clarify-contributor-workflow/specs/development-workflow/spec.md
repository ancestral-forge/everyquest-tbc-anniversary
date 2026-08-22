## ADDED Requirements

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

## MODIFIED Requirements

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
