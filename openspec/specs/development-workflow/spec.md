# Development Workflow Specification

## Purpose

Define the repeatable planning, isolation, validation, and evidence workflow for
EveryQuest changes made by humans or AI agents.

## Requirements

### Requirement: Isolated implementation state
Implementation SHALL start from a recorded repository state and SHALL preserve
unrelated work by using a clean, separate worktree on a task-named branch based
on the current canonical main branch.

#### Scenario: Starting an implementation task
- **WHEN** an agent is authorized to modify the repository
- **THEN** it records the branch, SHA, worktree list, and dirty state before editing
- **AND** it performs implementation outside the primary checkout on a task-named branch

### Requirement: Spec-first material changes
Material behavior, data-contract, architecture, CI, packaging, installation,
and release changes SHALL have coherent OpenSpec proposal, specification,
design, and task artifacts before implementation is considered complete.

#### Scenario: Request changes observable behavior
- **WHEN** a request changes addon behavior or a delivery contract
- **THEN** an OpenSpec change defines scope, non-goals, requirements, design decisions, tasks, and required evidence

#### Scenario: Request is read-only or mechanical
- **WHEN** work is limited to investigation or a typo with no changed behavior or acceptance criteria
- **THEN** the agent may skip a new OpenSpec change
- **AND** it states the reason for the skip

### Requirement: Mandatory local verification gate
Every implementation SHALL pass `tools/verify-addon.sh` before it is described
as locally validated.

#### Scenario: Implementation is ready for review
- **WHEN** source edits are complete
- **THEN** the gate checks repository whitespace, Luacheck, Lua 5.1 compatibility, XML, TOC consistency and references, and checked-in regression tests
- **AND** any failing check prevents a locally validated claim

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
