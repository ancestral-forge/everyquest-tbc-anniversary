## 1. Establish current state

- [x] 1.1 Confirm the clean `ai-workflow-openspec` worktree, current `origin/main`, and existing reusable linter workflow before editing
- [x] 1.2 Verify from official action documentation that setup-node v6 supports an explicit Node.js 24 runtime and disabled package-manager caching

## 2. Add OpenSpec CI validation

- [x] 2.1 Add an independent `OpenSpec validation` job using checkout v7, setup-node v6 with Node 24 and caching disabled, and the pinned OpenSpec 1.10.0 validation command
- [x] 2.2 Add the OpenSpec CI requirement to the living development-workflow spec and validate it against the delta spec

## 3. Validate the workflow

- [x] 3.1 Run the exact pinned `npx --yes @fission-ai/openspec@1.10.0 validate --all` command successfully
- [x] 3.2 Parse the workflow YAML and run `openspec validate --all`, `tools/verify-addon.sh`, and `git diff --check`
- [x] 3.3 Confirm no package, install, live-client, push, PR, merge, tag, or release action was performed
