## Why

OpenSpec artifacts are now part of the repository contract, but CI currently
validates only addon code and files. A malformed or inconsistent spec can merge
without any automated feedback even though the addon gate remains green.

## What Changes

- Add an independent `OpenSpec validation` job to the reusable linter workflow.
- Set up Node.js 24 without package-manager caching and run the exact pinned
  OpenSpec 1.10.0 CLI.
- Validate tracked OpenSpec specs and changes with `openspec validate --all`.
- Keep this job separate from Lua/addon validation and never run OpenSpec
  proposal, apply, sync, or archive operations in CI.

## Non-goals

- Do not infer whether a commit was produced by a human or AI agent.
- Do not enforce worktree, planning order, or authorship through CI.
- Do not modify addon runtime, packaging, release publication, or live-client
  behavior.
- Do not introduce a repository `package.json` solely for this check.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `development-workflow`: require CI to validate the structural consistency of
  tracked OpenSpec artifacts independently from addon validation.

## Impact

The change affects `.github/workflows/linter.yml` and the development-workflow
specification. The reusable release gate will inherit the new job automatically.
Required evidence is the exact pinned CLI command, YAML parsing, OpenSpec
validation, the existing addon gate, and diff review. No installed-client or
live WoW evidence is applicable.
