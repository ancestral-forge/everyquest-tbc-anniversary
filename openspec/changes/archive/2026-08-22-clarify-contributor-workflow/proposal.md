## Why

The initial agent workflow protects the project, but its wording can make
OpenSpec and separate worktrees appear mandatory for human contributors and
small changes. The project needs strict AI guardrails without turning a first
contribution into a process exercise.

## What Changes

- Define a lightweight human path: branch, focused change, local gate when
  available, and pull request.
- Make the separate-worktree and plan-first rules explicitly AI-agent rules.
- Require OpenSpec for high-risk or durable contract changes, while allowing an
  issue or pull-request description to carry ordinary bug fixes and small
  features.
- Keep the validation gate and evidence separation as project-wide technical
  protections.
- Make the validation gate discover and run every checked-in
  `tools/test-*.lua` regression test automatically.

## Non-goals

- Do not relax the TBC Anniversary, Lua 5.1, licensing, SavedVariables, or
  Blizzard-owned UI contracts.
- Do not remove OpenSpec or weaken CI enforcement.
- Do not require human contributors to install AI tooling.
- Do not change addon runtime behavior.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `development-workflow`: distinguish the lightweight human contribution path
  from stricter AI execution rules and narrow mandatory OpenSpec usage to
  high-risk or durable contract changes.

## Impact

The change updates `AGENTS.md`, the `everyquest-addon-development` skill,
`CONTRIBUTING.md`, OpenSpec workflow context and requirements, and
`tools/verify-addon.sh`. No addon module, SavedVariables, packaging, installed
client, or live WoW behavior changes. Required evidence is skill validation,
OpenSpec validation, the complete local addon gate, shell lint, and diff review;
live-client evidence is not applicable.
