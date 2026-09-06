## 1. Planning And Worktree

- [x] 1.1 Fetch current `origin/main`, inspect branch/SHA/worktree state, and create a clean `initialize-all-quest-data-on-login` worktree from latest `origin/main`; verify with `git status --short --branch`, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git worktree list --porcelain`.
- [x] 1.2 Create proposal, addon-runtime delta spec, design, and task artifacts for `initialize-all-quest-data-on-login`; verify `openspec status --change initialize-all-quest-data-on-login` reports the planning artifacts present.

## 2. Checkpoint 1: Loading And Preparation Split

- [x] 2.1 Implement the load-only quest-data boundary and verify it returns existing loaded data cheaply, loads missing modules without preparation side effects, reports normalized failure reasons, avoids chat output, avoids `collectgarbage("collect")`, and leaves failed attempts retryable.
- [x] 2.2 Implement the one-time group preparation boundary and verify it registers loaded data, hydrates history, synchronizes completed flags with `reportStatus=false`, records `sessionvars.preparedGroups`, returns structured statistics, and remains a cheap no-op after successful preparation.
- [x] 2.3 Keep `LoadQuestData(group)` as a compatibility adapter and verify it returns the group table on success, returns `false` on failure, preserves missing/disabled/load-failure/NO_DATA failure meanings, suppresses duplicate failure chat per group per session, never prints success, and retries internally.
- [x] 2.4 Add focused Lua 5.1 regression coverage for first and repeated preparation, QuestStore-preloaded groups, quiet success, retryable deduplicated failures, distinguishable failure reasons, static quest record immutability, and existing indexed lookup/history behavior; verify the focused test passes.
- [x] 2.5 Add a `[Unreleased]` changelog entry describing reduced repetitive quest-data loading/synchronization messages when browsing zones; verify the entry is accurate and does not mention version, package, install, or release work.

## 3. Checkpoint 1 Validation

- [x] 3.1 Run all affected QuestStore/history/status regression tests and verify they pass.
- [x] 3.2 Run `tools/verify-addon.sh` and verify it passes.
- [x] 3.3 Run `openspec validate --all`, strict validation of `initialize-all-quest-data-on-login`, and `git diff --check`; verify all pass.
- [x] 3.4 Inspect every complete changed function and the full diff against `origin/main`; verify the diff stays within checkpoint 1 scope.
- [x] 3.5 Create one local checkpoint commit with message `refactor: separate quest data loading from group preparation`; verify `git status --short --branch` is clean afterward.
- [x] 3.6 Install the checkpoint into the TBC Anniversary client, verify source/install parity, and confirm the requested in-game smoke path after `/reload`.

## 4. Later Checkpoint: Startup Initialization

- [ ] 4.1 Add `InitializeAllQuestData` to prepare all groups on startup through the checkpoint 1 preparation boundary; verify missing, disabled, failed, or empty groups remain retryable.
- [ ] 4.2 Wire startup initialization into the appropriate post-setup order without changing SavedVariables schema or quest-data module contents; verify current startup, quest-log scan, and zone browsing behavior in the TBC Anniversary client.
- [ ] 4.3 Replace per-group startup chatter with one aggregated startup summary using the checkpoint 1 preparation statistics; verify ordinary browsing no longer emits repetitive load/sync messages.
