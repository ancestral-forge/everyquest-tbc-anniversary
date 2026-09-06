## 1. Reconfirm implementation boundary

- [x] 1.1 Reinspect the canonical checkout and isolated worktree branch, SHA, worktree list, and dirty state; verify implementation remains on `quest-api-audit-scanner` based on current `origin/main` and record any drift before editing.
- [x] 1.2 Read `proposal.md`, `design.md`, `specs/quest-api-audit/spec.md`, the current slash-command path, SavedVariables setup, LOD loader, and verifier; verify the implementation plan still matches current code before adding files.

## 2. Focused automated coverage

- [x] 2.1 Add `tools/test-quest-api-audit.lua` with a minimal Lua 5.1-compatible fake WoW environment and production-module loader; verify the test file executes directly without external libraries.
- [x] 2.2 Cover all-module collection, positive-ID filtering, de-duplication, ascending order, disabled/missing/load-failed/no-data module aborts, and no automatic enabling; verify the focused test reports each collector scenario passing.
- [x] 2.3 Cover bounded first-pass stepping, retry-only stepping, transient recovery, double-missing unavailability, per-ID API errors, unsupported API, duplicate starts, status, and cancellation cleanup; verify the focused state-machine tests pass.
- [x] 2.4 Cover atomic compact-report replacement, build/interface/locale/version metadata, sorted anomaly IDs, failed/cancelled report preservation, clear semantics, old SavedVariables compatibility, and history/UI state non-mutation; verify the focused persistence and command tests pass.

## 3. Scanner implementation

- [x] 3.1 Add `EveryQuest/QuestApiAudit.lua` with the fixed ten-module read-only loader and pure deterministic ID collector; verify collector and module-failure tests pass without calling the mutating `LoadQuestData` path.
- [x] 3.2 Implement the private-frame bounded two-pass `C_QuestLog.GetQuestInfo` state machine, defensive probe classification, progress, duplicate-run prevention, and terminal cleanup; verify focused lifecycle tests pass under Lua 5.1.
- [x] 3.3 Implement atomic optional `EveryQuestDBPC.char.questApiAudit` persistence plus status/cancel/clear entry points; verify report-shape, rollback-compatibility, cancellation, clearing, and non-mutation tests pass.
- [x] 3.4 Load the scanner from `EveryQuest/EveryQuest.toc` and route `audit-api`, `audit-api status`, `audit-api cancel`, and `audit-api clear` from `EveryQuest/Options.lua` without adding regular help or options UI; verify command-routing and startup-no-scan tests pass.

## 4. Maintainer documentation

- [x] 4.1 Add a compact quest API audit section to `CONTRIBUTING.md` covering start/status/cancel/clear, progress, SavedVariables flushing/location, client metadata, and memory reclamation after reload; verify every shipped command and stored field is documented.
- [x] 4.2 Document triage categories (`phase-pending`, `legacy/retired`, `seasonal`, `data defect`) and require a post-unlock/build rerun, external provenance, and live confirmation before quest-data edits; verify the text explicitly says API title presence is not phase/obtainability proof and unavailable output never justifies automatic hiding or deletion.
- [x] 4.3 Confirm `README.md` and the player help/options surfaces do not advertise the maintainer audit; verify repository search finds the command only in implementation, focused tests, OpenSpec artifacts, and `CONTRIBUTING.md`.

## 5. Static and automated evidence

- [x] 5.1 Run `openspec validate add-quest-api-audit-scanner --strict` and keep this task unchecked until the command succeeds against the completed artifacts and implementation.
- [x] 5.2 Run `tools/verify-addon.sh` and keep this task unchecked until the required repository gate, including `tools/test-quest-api-audit.lua`, succeeds.
- [x] 5.3 Inspect `git diff --check`, the final scoped diff, and worktree status; verify there are no whitespace errors, generated artifacts, unrelated edits, or unexpected package/release/install changes.

## 6. Human client evidence

- [x] 6.1 With separate installation authorization, install the exact candidate into a TBC Anniversary Interface 20506 client and verify source/install file parity independently of static test results.
- [x] 6.2 In the human-operated client, enable script errors, reload, confirm ordinary startup performs no audit, start and cancel one run during cache warm-up, then complete a run while checking probe/warm-up status and unchanged quest history/UI; retain this task unchecked until the live path succeeds.
  - Human live confirmation (2026-09-05): after enabling script errors and reloading, ordinary startup did not start an audit; warm-up status and cancellation were exercised, a subsequent audit completed, and quest history/UI remained unchanged.
- [x] 6.3 Reload or log out to flush SavedVariables, inspect the saved compact report, and verify its addon/client/build/interface/locale metadata, counts, sorted anomaly IDs, and preservation across a run cancelled during cache warm-up; retain this task unchecked until the live file evidence is captured.
  - Human cancellation evidence confirmed that status still exposed the preceding complete 264-ID report before the final rerun. The flushed final report completed in 11 seconds with format 1, addon 2026.3.6, client 2.5.6.69546, Interface 20506, locale enUS, 6,176 total, 5,912 available, 264 unavailable, and 0 errors; its 264 unique IDs are strictly ascending and exactly match the prior warmed report.
- [x] 6.4 Classify the current unavailable IDs without changing quest data, mark not-yet-unlocked content as phase-pending, and record which candidates still need provenance and a post-phase live recheck; retain this task unchecked until a live complete report exists.
  - Live evidence (2026-09-05): on client 2.5.6.69546 a cold-cache run completed 6,176 IDs with 1,793 available, 4,383 unavailable, and 0 probe errors; a follow-up complete run after reload reported 5,912 available, 264 unavailable, and 0 probe errors. The second unavailable set was a strict subset of the first: 4,119 IDs recovered and no new ID became unavailable. Conservative triage of the warmed result records 21 direct Isle of Quel'Danas/Magisters' Terrace IDs as `phase-pending-direct-zone`, 39 as `seasonal-review`, and 204 as `needs-provenance`; all unavailable candidates require a later live recheck, and no quest data was changed.

## 7. Cold-cache retry hardening

- [x] 7.1 Record the cold-versus-warmed live result and reconcile the proposal, specification, design, and human-client acceptance path around a bounded probe-free ten-second warm-up before the retry pass.
- [x] 7.2 Extend the Lua 5.1 harness to prove no retry probe occurs before ten elapsed seconds, retry starts after the boundary, warm-up status is observable, and cancellation during warm-up preserves the previous report.
- [x] 7.3 Implement the warm-up state through the existing private frame and document the expected delay without adding timers, events, dependencies, extra retry rounds, or player-facing discoverability.
- [x] 7.4 Run the focused test, `tools/verify-addon.sh`, strict and all-change OpenSpec validation, final diff checks, then install the exact revised candidate and prove source/install parity before requesting the final human-client run.

Package publication, remote CI, commit/push, merge, tag, and release are outside this change's current authorization and acceptance criteria. If later requested, each must be tracked and reported as a separate evidence layer rather than inferred from the checks above.
