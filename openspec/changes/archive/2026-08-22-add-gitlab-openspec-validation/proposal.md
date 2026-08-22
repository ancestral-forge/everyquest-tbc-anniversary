## Why

GitHub now validates tracked OpenSpec artifacts, but GitLab release-tag
pipelines can still publish backup releases after running only Lua checks. The
backup release gate should enforce the same specification integrity before
publication without expanding GitLab into a second pull-request platform.

## What Changes

- Add an independent `openspec` test job to GitLab release-tag pipelines.
- Run the pinned OpenSpec 1.10.0 CLI in the official Node 24 Alpine image with
  telemetry disabled.
- Make `publish-release` depend on both the existing Lua job and the new
  OpenSpec job.
- Preserve the current GitLab workflow rules: tag releases, scheduled backup
  sync, and manual sync only.

## Non-goals

- Do not enable GitLab branch or merge-request pipelines.
- Do not alter scheduled or manual GitHub-to-GitLab synchronization.
- Do not infer human or AI authorship or mutate OpenSpec artifacts in CI.
- Do not change addon code, packaging, release scripts, or live behavior.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `development-workflow`: extend independent OpenSpec validation from GitHub to
  GitLab release-tag pipelines and require it before backup publication.

## Impact

The change affects `.gitlab-ci.yml` and the development-workflow spec. Required
evidence is YAML parsing, the exact pinned OpenSpec command, OpenSpec validation,
the addon gate, and diff review. A live GitLab pipeline remains pending until
the branch is pushed and the release-tag path is exercised; package, install,
and live WoW evidence are not applicable to this local change.
