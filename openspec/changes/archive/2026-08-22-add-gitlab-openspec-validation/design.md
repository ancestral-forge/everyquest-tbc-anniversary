## Context

GitLab is a backup target. Its workflow admits release tags, schedules, and
manual web pipelines; only release tags run the Lua and publication jobs. GitHub
already exposes OpenSpec validation independently from Lua validation. See
`proposal.md` and the development-workflow delta for the desired parity.

## Goals / Non-Goals

**Goals:**

- Gate GitLab backup releases on the same pinned OpenSpec validation contract.
- Keep Lua and OpenSpec results independently visible.
- Preserve current tag, schedule, and manual workflow boundaries.

**Non-Goals:**

- Do not add GitLab branch or merge-request validation.
- Do not duplicate GitHub's canonical PR workflow.
- Do not change release or synchronization scripts.

## Decisions

### Add a tag-only test-stage job

Add `openspec` beside `lua` with the same release-tag rule. Scheduled and manual
sync pipelines will continue to create only `sync-github`; this avoids an npm
dependency in backup reconciliation that does not publish a release.

Alternative considered: run OpenSpec in all admitted GitLab pipelines. That
would couple scheduled backup sync to a specification tool without protecting
an additional publication path.

### Use the official Node 24 Alpine image

Run in `node:24-alpine`, which supplies Node and npx directly and keeps the job
small. Set `OPENSPEC_TELEMETRY` to `0` and invoke the exact
`@fission-ai/openspec@1.10.0` package.

Alternative considered: install Node into `alpine:3.22`. The official Node
image expresses the runtime contract directly and avoids package-manager setup.

### Add both test jobs to release needs

Change `publish-release.needs` from only `lua` to `lua` and `openspec`. GitLab
can run the two test jobs concurrently, while the release job starts only when
both succeed.

Alternative considered: call OpenSpec from the Lua job. This would mix two
independent evidence layers and require Node in the Luacheck image.

## Risks / Trade-offs

- [Docker Hub or npm availability can block a backup release] -> Keep exact
  runtime and CLI versions visible and isolate failures in the OpenSpec job.
- [Node major image receives patch updates] -> Pin the OpenSpec validator exactly
  and intentionally retain Node 24 security updates within the declared major.
- [No local GitLab runner proof] -> Validate YAML and the exact CLI locally,
  then report the real tag pipeline as pending until pushed and exercised.

## Migration Plan

Add the test job and release dependency, update and sync the living spec, then
run local OpenSpec and addon validation. Reverting the CI job, dependency, and
spec restores the previous backup release gate; no addon or data migration is
involved.
