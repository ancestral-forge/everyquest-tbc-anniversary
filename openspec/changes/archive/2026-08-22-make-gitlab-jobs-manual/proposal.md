## Why

GitLab is a backup target with limited CI minutes, but its admitted tag,
scheduled, and web pipelines currently start runner jobs automatically. The
pipeline should expose the available operations without spending runner time
until a maintainer explicitly starts a job.

## What Changes

- Make every GitLab job a blocking manual action in each rule that creates it.
- Keep release-tag pipelines exposing `lua`, `openspec`, and
  `publish-release`, with publication still dependent on both validation jobs.
- Keep scheduled and web pipelines exposing `sync-github`, but require a
  maintainer to start the synchronization explicitly.
- Preserve GitHub CI and GitHub-to-GitLab push mirroring unchanged.

## Non-goals

- Do not add GitLab branch or merge-request pipelines.
- Do not automatically start any GitLab runner job.
- Do not change addon code, compatibility, packaging, release, or sync scripts.
- Do not require contributors to use AI tooling or OpenSpec locally.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `release-delivery`: require explicit maintainer activation for every job
  exposed by GitLab release, scheduled, and web pipelines.

## Impact

The change affects `.gitlab-ci.yml` and the release-delivery specification. It
does not affect addon modules, SavedVariables, packaged files, or WoW client
behavior. Required evidence is YAML parsing, OpenSpec validation, the addon
gate, and diff review; live GitLab UI and runner behavior remain pending until
the branch is pushed and an admitted pipeline is created. Package, install,
and live WoW client evidence are not applicable.
