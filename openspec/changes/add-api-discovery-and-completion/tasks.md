## 1. Preparation and dependency

- [x] 1.1 Recheck branch, SHA, worktrees and dirty state against fresh main; read runtime contract and all apply context files, recording drift before implementation.
- [x] 1.2 Import only the reviewed local overlay runtime/tests/change into this worktree without modifying its source worktree; verify its focused tests and scoped diff.

## 2. Commands and discovery

- [x] 2.1 Implement grouped routing and rename diagnostic usage strings; test audit subcommands, overlay toggle, old-name rejection and preserved ordinary commands.
- [x] 2.2 Implement strict range validation, bounded throttled probing, warming and one delayed retry; test boundaries, invalid input, low/high frame rates, missing APIs and exceptions.
- [x] 2.3 Implement status/cancel/clear and atomic discovery report; test duplicate titles, count partition, sorted errors, duplicate starts, cancellation in each phase, reload persistence through Core initialization, schema compatibility and unchanged audit/history data.

## 3. Completion and documentation

- [x] 3.1 Implement pure scoped completion and the chained custom-Tab extension; test unique/ambiguous prefixes, case, whitespace, numeric hints, accepted selection clearing and mid-line preservation, no dispatch, original callback return values and missing extension.
- [x] 3.2 Update CONTRIBUTING and reconcile active audit/overlay specs while retaining historical evidence; search for stale actionable command examples and verify README/changelog remain unchanged under the explicit developer-only decision.

## 4. Automated evidence

- [x] 4.1 Run tools/verify-addon.sh with all new tests and inspect complete changed functions, final diff and git status.
- [x] 4.2 Run strict change validation and openspec validate --all after implementation and task updates.

## 5. Client evidence

- [x] 5.1 After separate authorization, install every EveryQuest addon directory and verify each source/install pair with diff -qr.
- [ ] 5.2 With script errors enabled, verify grouped audit/discovery/overlay, bounded small-range completion, cancellation, reload flush and preserved history/report data in Anniversary.
- [ ] 5.3 Verify Tab completion in ordinary and temporary chat edit boxes, normal player-name/whisper completion, mid-line/selected text, numeric hints and no accidental command execution; check both out of combat and in combat with installed chat addons.

Commit, push, PR, merge and release remain separately authorized actions. No task is complete from planning or from a prior build's live evidence.

## Implementation checkpoint (2026-09-06)

Discovery, grouped routing and imported overlay passed tools/verify-addon.sh (14 scripts) before completion implementation. The selection issue was resolved by explicit user acceptance on 2026-09-06: with cursor at end, Tab completion may clear highlighting. At that checkpoint, the original overlay worktree and installed client were unchanged; the authorized installation followed later (task 5.1).

## Publication checkpoint (2026-09-06)

The user authorized publishing discovery, completion and overlay together. The
publication branch starts from main 1087df0; original dirty implementation
worktrees are preserved.

Publication validation passed: tools/verify-addon.sh (15 Lua regression scripts,
Luacheck, Lua 5.1 compatibility, XML and TOC checks), strict validation of both
new changes, and openspec validate --all (12 items). The final staged diff was
reviewed; README and CHANGELOG are unchanged under the developer-only decision.

The user completed discovery in Anniversary 2.5.6, build 69546, enUS, for IDs
1..100000: 6442 titles, 93558 missing responses and 0 errors. The persisted
result was inspected and used for the research report merged in PR #40; see
[scan-summary.json](../../../docs/research/quest-api-2026-09-06/scan-summary.json).
This confirms a complete discovery run and saved output, not the entire task
5.2 cancellation/history matrix or task 5.3 live chat-completion matrix. Both
tasks remain unchecked. No new installation, merge or release is part of this
publication checkpoint.
