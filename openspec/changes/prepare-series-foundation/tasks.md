## 1. Work State and Contract

- [x] 1.1 Confirm `prepare-series-foundation` is a clean separate worktree based on current `origin/main`; verify with `git status --short --branch`, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git worktree list --porcelain`.
- [x] 1.2 Re-read this change's proposal, addon-runtime delta, design, and apply instructions, then run the unchanged baseline `tools/verify-addon.sh` successfully before implementation.

## 2. Isolate Character History from Static Data

- [x] 2.1 Add the directly loadable Lua 5.1 `QuestStore` module and TOC entry with `CreateHistoryRecord` and `EnsureHistoryRecord`; verify `tools/test-quest-store.lua` proves records are fresh tables containing only `id`, `n`, `l`, `r`, `s`, `t`, and `d` from static data.
- [x] 2.2 Route completed-flag sync, `AddQuestByID`, manual `UpdateStatus`, save, and removal paths through store-owned history creation/removal; verify the focused test mutates history status and proves the static quest is unchanged and relation fields are absent.
- [x] 2.3 Preserve schema version 1 and existing flat history fields without an eager migration; verify store and existing history/status regressions pass under Lua 5.1.
- [x] 2.4 Create the review checkpoint `refactor: isolate character history from static quest data` and verify the commit contains only the OpenSpec foundation plus the history-isolation implementation and tests.

## 3. Introduce Indexed Quest Lookup

- [ ] 3.1 Extend `QuestStore` with one-time history indexing, idempotent loaded-group registration, static/history/location lookup, and canonical move/remove index maintenance; verify repeated indexed lookup and stale-location cases in `tools/test-quest-store.lua`.
- [ ] 3.2 Preserve the ordered load-on-demand fallback without editing the ten data modules; verify a hinted group is tried first, successfully loaded groups are registered once, unresolved IDs return no static location, and later indexed hits do not invoke the loader again.
- [ ] 3.3 Convert `GetQuestData`, `GetHistoryByQuestID`, canonical lookup, hydration, save, add, Clear Status, and reconciliation paths into store consumers/adapters; verify `tools/test-unmapped-quest-history.lua`, `tools/test-history-hydration.lua`, and `tools/test-quest-status-model.lua` pass.
- [ ] 3.4 Create the review checkpoint `refactor: introduce indexed quest store` and verify its diff is limited to store indexing, compatibility adapters, and their regression coverage.

## 4. Extract Normalized Quest Relations

- [ ] 4.1 Add the directly loadable Lua 5.1 `QuestRelations` module with normalized `requiresAll`, `requiresAny`, `breadcrumbs`, `exclusiveWith`, and `followUps` arrays, bundled source provenance, deduplication, direct-self rejection, and reverse follow-up indexing; verify these cases in `tools/test-quest-relations.lua`.
- [ ] 4.2 Add the guarded optional Questie adapter for `nextQuestInChain`; verify valid successes are cached while absent, disabled, malformed, throwing, nil, non-finite, fractional, zero, negative, and out-of-range results fail open and remain retryable.
- [ ] 4.3 Route the current skipped-chain Unavailable lookup through `QuestRelations` without changing status precedence; verify the standalone relations test and updated `tools/test-quest-chain-status.lua` preserve every current Questie and embedded-data scenario without extracting relation helpers from source text.
- [ ] 4.4 Create the review checkpoint `refactor: extract current chain lookup into quest relations service` and verify no Series UI or imported relationship dataset is present.

## 5. Expose Structured Quest State

- [ ] 5.1 Add the directly loadable Lua 5.1 `QuestState` module with separate progress and availability results, manual versus derived sources, `REQUIRED_LEVEL` and `CHAIN_ADVANCED` reasons, legacy abandoned interpretation, and a numeric legacy adapter; verify `tools/test-quest-state.lua` covers every stored status and derived rule.
- [ ] 5.2 Make rows, filters, tooltips, and context-menu status checks consume the legacy adapter while lifecycle handlers continue to own stored progress; verify updated chain/status/context-menu regressions preserve numeric precedence, labels, colors, and Clear Status behavior without extracting state helpers from source text.
- [ ] 5.3 Verify QuestState returns unknown availability and the legacy adapter returns nil when no stored status or valid unavailable reason exists, including with Questie absent.
- [ ] 5.4 Create the review checkpoint `refactor: expose structured quest state` and verify the complete four-checkpoint history is linear and based on the recorded `origin/main` SHA.

## 6. Local Validation and Diff Review

- [ ] 6.1 Run `mise exec lua@5.1.5 -- lua tools/test-quest-store.lua`, `mise exec lua@5.1.5 -- lua tools/test-quest-relations.lua`, `mise exec lua@5.1.5 -- lua tools/test-quest-state.lua`, `mise exec lua@5.1.5 -- lua tools/test-quest-chain-status.lua`, `mise exec lua@5.1.5 -- lua tools/test-quest-status-model.lua`, `mise exec lua@5.1.5 -- lua tools/test-unmapped-quest-history.lua`, and `mise exec lua@5.1.5 -- lua tools/test-history-hydration.lua` successfully.
- [ ] 6.2 Run the required local gate `tools/verify-addon.sh` successfully and retain its Luacheck, Lua 5.1, XML, TOC, whitespace, and full regression-test evidence.
- [ ] 6.3 Run `openspec validate --all` successfully after implementation.
- [ ] 6.4 Inspect `git diff origin/main...HEAD`, every complete changed function, commit history, and final `git status --short --branch`; verify schema version 1, Interface `20506`, optional Questie, original attribution/provenance, existing data modules, XML/UI layout, lifecycle ownership, and packaging workflows remain unchanged outside the approved adapters and TOC load order.

## 7. External Evidence and Delivery

- [ ] 7.1 In a human-run TBC Anniversary client with script errors enabled, verify addon load with Questie enabled and disabled plus existing zone/history rendering, manual statuses, Clear Status, accept, ready, complete, turn-in, abandon, and fail paths; record this separately from local checks.
- [x] 7.2 If installation is explicitly authorized, sync only the `EveryQuest*` addon directories and prove repository/client parity separately from live gameplay; do not modify SavedVariables.
- [ ] 7.3 Push or open a pull request only after explicit authorization, then verify the remote head SHA and remote CI separately from local and live-client evidence.
- [ ] 7.4 Merge, package, tag, publish, or release only after separate explicit authorization, verifying each resulting state independently.
