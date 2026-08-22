## Context

The reusable linter workflow currently has one Lua job and is called by the
release workflow. OpenSpec artifacts are tracked but validated only by local
commands. See `proposal.md` and the development-workflow delta for the intended
CI contract.

## Goals / Non-Goals

**Goals:**

- Surface OpenSpec validity as its own GitHub Actions job.
- Use a reproducible CLI and Node runtime without adding project package files.
- Preserve the existing reusable-workflow and release-gate behavior.

**Non-Goals:**

- Do not combine addon and specification results into one opaque step.
- Do not detect AI authorship or reconstruct planning history.
- Do not mutate OpenSpec artifacts from CI.

## Decisions

### Add a second job to the existing reusable workflow

Add `openspec` beside `lua` in `.github/workflows/linter.yml`. This keeps one
required workflow entry point for pushes, pull requests, manual runs, and the
release workflow while preserving two independently visible job results.

Alternative considered: create a path-filtered workflow. A skipped workflow can
interact poorly with required-check configuration, and it would not
automatically participate in the existing reusable release gate.

### Use Node.js 24 through setup-node v6

Use `actions/setup-node@v6` with `node-version: 24` and
`package-manager-cache: false`. The OpenSpec CLI requires modern Node, while the
repository has no package manifest or dependency cache to restore.

Alternative considered: rely on the runner's preinstalled Node. That makes the
job depend on a moving runner-image default rather than declaring its runtime.

### Pin the OpenSpec package and run only validation

Run `npx --yes @fission-ai/openspec@1.10.0 validate --all`. The exact package
version makes validation behavior reviewable without adding a `package.json` or
lockfile. CI will not run proposal, apply, sync, archive, or any command that
writes planning artifacts.

Alternative considered: install `@latest`. That could change validation rules
without a repository diff.

## Risks / Trade-offs

- [npm registry availability can fail the job] -> Pin the version and keep the
  job isolated so the failure is clearly infrastructure-related.
- [The exact CLI version needs maintenance] -> Update it explicitly through a
  reviewed CI-contract change when OpenSpec artifacts are regenerated.
- [Validation runs on PRs that do not touch specs] -> Accept the small cost to
  keep required-check behavior predictable and verify the tracked contract.

## Migration Plan

Add the job, execute its exact CLI command locally, parse the workflow YAML, and
run both OpenSpec and addon validation. Archive the change after the living spec
is synced. Reverting the job and requirement restores the previous behavior;
there is no addon or data migration.
