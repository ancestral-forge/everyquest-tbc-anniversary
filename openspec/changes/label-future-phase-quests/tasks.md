## 1. Reconfirm implementation boundary

- [x] 1.1 Reinspect the canonical checkout and isolated worktree branch, SHA, worktree list, and dirty state; verify implementation remains on `show-future-content-phases` based on current `origin/main` without touching the user's `.codex-history-export/` or the scanner worktree.
- [x] 1.2 Read `proposal.md`, `design.md`, `specs/future-phase-labels/spec.md`, the complete title/status formatting functions, localization table, affected quest-data sections, and verifier before editing; verify the implementation plan still matches current code.

## 2. Phase inventory and focused coverage

- [x] 2.1 Inventory all shipped quest IDs corroborated as Phase 4/5-gated, including Zul'Aman and Shattered Sun/Quel'Danas/Magisters' Terrace/Sunwell content, their module/zone occurrences, and duplicate records; leave scanner-only or ambiguous candidates unmarked.
- [x] 2.2 Add `tools/test-future-phase-labels.lua` with a Lua 5.1-compatible production-code harness; verify exact `[level/type][Phase 4/5] title` formatting, enabled/disabled phase flags, unsupported/unmarked phases, localization, and ordering with Failed/Abandoned suffixes.
- [x] 2.3 Extend the focused test to load affected data modules and assert the reviewed Phase 4/5 ID inventory, allowed metadata values, and identical phase values for every duplicate occurrence; verify the pre-implementation data assertions fail for the missing metadata.

## 3. Metadata and presentation implementation

- [x] 3.1 Add compact numeric `p = 4` metadata to every reviewed Zul'Aman quest occurrence and `p = 5` to every reviewed Shattered Sun/Quel'Danas/Magisters' Terrace/Sunwell occurrence without changing other record fields or order; verify the focused inventory and duplicate-consistency assertions pass.
- [x] 3.2 Add independent module-local Phase 4 and Phase 5 release flags, the localized `Phase` token, and a pure phase-marker formatter; verify focused tests cover both flags enabled, each flag independently disabled, both disabled, and malformed metadata.
- [x] 3.3 Compose the phase marker in `EveryQuest:UpdateButton` immediately after `[level/type]` and before the title and existing lifecycle suffix, without changing status, row color, sorting, tooltip, link, or click paths; verify focused rendering/status-composition tests pass.

## 4. Static and automated evidence

- [x] 4.1 Run `mise exec lua@5.1.5 -- lua tools/test-future-phase-labels.lua` and keep this task unchecked until every focused data and presentation scenario passes under Lua 5.1.
- [x] 4.2 Run `openspec validate label-future-phase-quests --strict` and `openspec validate --all`; keep this task unchecked until both the new change and complete OpenSpec tree validate.
- [x] 4.3 Run `tools/verify-addon.sh` and keep this task unchecked until the full required repository gate succeeds, including the new regression test.
- [x] 4.4 Inspect the complete changed functions, data diff, `git diff --check`, and final worktree status; verify there are no unrelated edits, accidental quest-field changes, SavedVariables changes, package changes, or scanner-worktree changes.

## 5. Human client evidence

- [x] 5.1 With separate installation authorization, install the exact candidate into TBC Anniversary Interface 20506 and prove repository/install file parity independently of static tests.
- [ ] 5.2 In the human-operated client, enable script errors, `/reload`, inspect representative short and long Phase 4/5 rows plus status-bearing rows, and verify marker/title/status order, clipping, colors, sorting, tooltip, links, and clicks; keep this task unchecked until the live path succeeds.

Package publication, remote CI, commit/push, merge, tag, and release are outside this change's current authorization. If later requested, keep each delivery state separate from static validation, install parity, and live gameplay evidence.
