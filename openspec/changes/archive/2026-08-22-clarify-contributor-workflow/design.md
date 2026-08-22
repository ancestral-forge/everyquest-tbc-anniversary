## Context

The initial workflow uses one vocabulary for agent safety and project
contribution requirements. See `proposal.md` for the resulting onboarding
problem and the development-workflow delta for the new contract.

## Goals / Non-Goals

**Goals:**

- Separate AI execution guardrails from human submission requirements.
- Keep high-risk decisions durable without requiring contributors to install AI
  tooling.
- Retain one machine-enforced validation path in local development and CI.

**Non-Goals:**

- Do not create separate technical quality standards for humans and agents.
- Do not change addon runtime, data, UI, packaging, or release behavior.
- Do not automate OpenSpec generation from pull requests.

## Decisions

### Keep strict rules in agent-owned files

`AGENTS.md` and the EveryQuest skill will explicitly address AI agents. Separate
worktrees, recorded state, plan-first execution, and evidence reporting remain
mandatory there because they prevent common agent failure modes.

Alternative considered: weaken the agent workflow to match the human path. This
would remove useful dirty-checkout and overclaim protections without improving
human onboarding.

### Give humans a conventional contribution path

`CONTRIBUTING.md` will lead with `branch -> focused change -> validation -> PR`.
Local validation is recommended, while the same CI gate remains authoritative
when a contributor lacks the local toolchain.

Alternative considered: require every contributor to run the local gate. This
would unnecessarily require Lua 5.1, Luacheck, and XML tools before a first PR.

### Make OpenSpec a maintainer-owned merge contract

OpenSpec is required before merge only for the enumerated high-risk or durable
contracts. A human can supply the intent through an issue or PR; a maintainer
can add the artifacts. Agents must create them before implementing such work.

Alternative considered: require OpenSpec for every behavior change. That adds
more planning artifacts than value for ordinary, focused patches.

### Discover regression tests by convention

The validation script will execute sorted `tools/test-*.lua` files rather than
maintaining a manual list. A checked-in test therefore enters both local and CI
validation automatically.

Alternative considered: keep an explicit list. The branch already gained new
tests that the original list did not include, demonstrating the maintenance
risk.

## Risks / Trade-offs

- [The OpenSpec threshold still requires judgment] -> List concrete high-risk
  categories and default ordinary focused work to issue/PR planning.
- [A high-risk human PR can arrive without artifacts] -> Make maintainers
  responsible for capturing them before merge, not contributors before submit.
- [Local environments vary] -> Keep CI authoritative and require honest
  reporting of checks that were not run locally.

## Migration Plan

Update the agent contract, skill, contributor guide, OpenSpec context and main
development-workflow spec together. Update the gate test discovery, validate
all artifacts and checks, then archive this change into the living spec. A
revert of this commit restores the previous workflow; no data migration or live
client rollback is involved.
