## 1. Establish GitLab CI context

- [x] 1.1 Inspect the clean worktree and current `.gitlab-ci.yml`, confirming release tags run `lua` then `publish-release` while schedule/web pipelines run only sync
- [x] 1.2 Verify the official `node:24-alpine` image exists and supplies the declared Node 24 runtime for the job

## 2. Add the GitLab release gate

- [x] 2.1 Add a tag-only `openspec` test job with telemetry disabled and the pinned OpenSpec 1.10.0 validation command
- [x] 2.2 Make `publish-release` need both `lua` and `openspec`, then verify scheduled and manual sync rules remain unchanged
- [x] 2.3 Update the living development-workflow requirement to cover GitHub and GitLab release-tag validation

## 3. Validate and preserve evidence boundaries

- [x] 3.1 Parse `.gitlab-ci.yml` and run the exact pinned OpenSpec command, `openspec validate --all`, `tools/verify-addon.sh`, and `git diff --check`
- [x] 3.2 Record live GitLab release-tag pipeline proof as pending because no push, tag, package, release, install, or live-client action is authorized
