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

## 4. Checkpoint 2: Startup Initialization

- [x] 4.1 Fetch and inspect current branch, SHA, dirty state, and worktrees; create fresh `initialize-all-quest-data-startup` from `origin/main` at `d36ff1e3446d32f61187794e73cc90aeab9ad62f`, preserving the merged checkpoint worktree and unrelated root changes.
- [x] 4.2 Update the existing proposal, design, delta spec, and tasks before implementation; preserve checkpoint 1 history and evidence.
- [x] 4.3 Implement `InitializeAllQuestData` using canonical group order and the preparation boundary; aggregate fresh statistics/failures, continue after failed groups, keep failures retryable, and leave compatibility failure deduplication untouched.
- [x] 4.4 Wire preparation, quiet scan, one summary, saved-view rendering, and initialized state in that order; preserve schema, static data, canonical precedence, and explicit scan reporting.
- [x] 4.5 Add correctly pluralized normal/warning summaries and quiet initial rendering, including failed saved-zone groups; retain normal later browsing reuse/retries.
- [x] 4.6 Update the existing Unreleased changelog bullet for login/reload preparation, one summary, and quiet browsing.

## 5. Checkpoint 2 Automated Validation

- [x] 5.1 Run `mise exec lua@5.1.5 -- lua tools/test-quest-data-startup.lua`: prove canonical attempts/order, direct preparation, failure isolation and retry, statistics, startup order and quiet scan, one normal/warning line, unmapped counts, later browsing, static record immutability, and schema version 1.
- [x] 5.2 Run the affected preparation, quest-store, history-hydration, unmapped-quest-history, quest-status-model, quest-log-fallback, and future-phase-labels Lua 5.1 tests.
- [x] 5.3 Run `tools/verify-addon.sh` successfully.
- [x] 5.4 Run `openspec validate --all`, `openspec validate initialize-all-quest-data-on-login --strict`, and `git diff --check` successfully.
- [x] 5.5 Inspect every complete changed function and the full diff against `origin/main`; verify checkpoint 2 scope and unchanged module data, schema, version, XML, and unrelated diagnostic/CI surfaces.

## 6. Checkpoint 2 Live Evidence (Separate Authorization Required)

- [x] 6.1 Install the checkpoint into TBC Anniversary and verify source/install parity after separate authorization.
- [x] 6.2 With script errors enabled, verify login and `/reload` each produce one summary, active states follow completed sync, and subsequent zone browsing stays quiet in the client.
- [x] 6.3 Verify a missing/disabled/failed/no-data group yields one startup warning summary and later user-driven browsing retries with one detailed failure; confirm recovery after a successful retry.

## 7. Checkpoint 2 Commit And Delivery

- [x] 7.1 Create one local commit `feat: initialize all quest data on login` and verify its complete contents and final clean status.
- [x] 7.2 Push/open a PR only after separate authorization; verify remote branch and PR contents.
- [x] 7.3 Verify remote CI after authorized delivery.
- [ ] 7.4 Merge only after separate authorization and required evidence; verify canonical main.

No package, version bump, tag, publication, or release is in checkpoint 2 scope.
Do not archive this change while the required automated or live evidence is pending.

## Checkpoint 2 Evidence

- Base: fetched `origin/main` = `d36ff1e3446d32f61187794e73cc90aeab9ad62f`
  (PR #42); fresh worktree `/private/tmp/everyquest-initialize-all-quest-data-startup`.
  Original root remains at `89caf03c1fc6253bc69ba86cc1137d544e5bb036` with its
  unrelated `.idea/`; the checkpoint 1 branch/worktree was not reused.
- Automated, 2026-09-06: focused startup test passed using
  `mise exec lua@5.1.5 -- lua tools/test-quest-data-startup.lua`. The full
  `tools/verify-addon.sh` gate passed Luacheck, Lua 5.1, XML, TOC, whitespace,
  and all 17 Lua regression files, including all seven requested affected tests.
  `lua5.1` is not on PATH; the gate used its existing mise fallback. Mise's
  optional cache-write warning did not prevent test execution or success.
- OpenSpec: `openspec validate --all` passed all 13 items; strict validation
  of this change and `git diff --check` passed.
- Source review: complete changed functions and full diff reviewed. Runtime
  changes are limited to startup orchestration, aggregate reporting, and quiet
  initial zone-data access. The compatibility adapter, explicit scan reporting,
  QuestStore precedence, schema version 1, static modules, XML, version, and
  unrelated diagnostics/CI remain unchanged.
- Local commit: `feat: initialize all quest data on login`; committed files
  match the reviewed worktree and clean status was verified.
- Installation, 2026-09-06 (user authorized): copied checkpoint
  `ad53dd6a964e23d3bf4f2b9bb5534e42adf6a63d` from its worktree into
  `/Applications/World of Warcraft/_anniversary_/Interface/AddOns` using
  per-directory `rsync -a --delete` for exactly 11 `EveryQuest*` directories.
  `.flavor.info` confirmed `wow_anniversary`; `diff -qr` passed for all 11
  source/install pairs. SavedVariables and other addons were not modified.
- Live client, 2026-09-06 (user-reported): the user confirmed the supplied
  main and additional test scenarios passed on the installed checkpoint.
  Login/reload produced one summary; subsequent zone browsing stayed quiet;
  active statuses and saved zone/view behaved as expected, with no reported
  Lua errors. The warning was traced to the intentionally disabled
  `EveryQuest_Outland`: 9/10 groups and one failed group, one detailed error on
  browsing that group, no duplicate error on repeated browsing, and recovery
  to 10/10 after re-enabling the module and reloading.
  Other failure reasons and recovery within the same session have automated
  harness coverage; this live confirmation covers the disabled-module path
  and recovery after reload.
- Before PR delivery, checkpoint 2 was local only. Delivery evidence is tracked
  separately in section 7; this change remains active and unarchived.

- Delivery, 2026-09-06 (user authorized): pushed
  `initialize-all-quest-data-startup` over SSH and created
  [PR #43](https://github.com/ancestral-forge/everyquest-tbc-anniversary/pull/43)
  targeting `main`. Verified the open PR's branch, base, seven changed files,
  body, and head `ca273cc719a830107e03bf15d634aea6416b888f` against the local
  checkpoint. Addon code is unchanged from the installed/live-tested revision.
- Remote CI: [Linter run 34054260715](https://github.com/ancestral-forge/everyquest-tbc-anniversary/actions/runs/34054260715)
  passed both Lua lint and OpenSpec validation for the implementation checkpoint;
  [GitLab mirror run 34054248303](https://github.com/ancestral-forge/everyquest-tbc-anniversary/actions/runs/34054248303)
  also passed. Subsequent delivery-evidence edits affect this document only.
  Merge and archive have not been performed.
