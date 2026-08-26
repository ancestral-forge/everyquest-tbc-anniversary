## 1. Setup and Spec Alignment

- [x] 1.1 Confirm the implementation is isolated in a separate worktree branch from current `origin/main`; verify with `git status -sb`, `git rev-parse --short HEAD`, and `git worktree list`.
- [x] 1.2 Inspect the affected OpenSpec runtime capability before finalizing scope; verify `openspec/specs/addon-runtime/spec.md` and this change's proposal, spec, and design artifacts exist.

## 2. Runtime Implementation

- [x] 2.1 Implement canonical quest-ID lookup from EveryQuest static quest data and verify quest-log history can route to the static bucket instead of the active Blizzard header bucket.
- [x] 2.2 Move an existing misplaced history entry to the canonical bucket without losing status, count, title, level, or timestamp metadata; verify with a focused Lua regression.
- [x] 2.3 Preserve quest level from the legacy quest-log fallback and separate legacy daily-frequency handling from native quest-log daily handling; verify with a focused Lua regression.
- [x] 2.4 Clear stale daily markers when static or quest-log metadata proves a quest is non-daily; verify with a focused Lua regression.

## 3. Regression and Local Verification

- [x] 3.1 Add or update focused Lua regression tests for canonical history routing, metadata hydration, and quest-log fallback behavior; verify the expected files under `tools/` changed.
- [x] 3.2 Add an unreleased `CHANGELOG.md` entry for the user-visible history routing and metadata fixes; verify the entry appears under `[Unreleased]`.
- [x] 3.3 Run focused Lua regressions with `mise exec lua@5.1.5 -- lua tools/test-quest-log-fallback.lua`, `mise exec lua@5.1.5 -- lua tools/test-history-hydration.lua`, and `mise exec lua@5.1.5 -- lua tools/test-unmapped-quest-history.lua`.
- [x] 3.4 Run the required local gate `tools/verify-addon.sh` and verify it exits successfully.

## 4. Client Evidence

- [x] 4.1 If authorized, install the built addon into the WoW TBC Anniversary client and verify install parity separately from local checks.
- [ ] 4.2 In the live WoW client, trigger the normal quest-log scan or hydration path, open EveryQuest Ironforge history, and verify Alliance Trauma is absent from Ironforge.
- [ ] 4.3 In the live WoW client, open the canonical First Aid/profession history path after the same scan or hydration and verify Alliance Trauma is present with preserved completion state.

## 5. Publication

- [x] 5.1 Inspect final diff and Git status before publication; verify only the intended runtime, test, and OpenSpec files are changed in the task worktree.
- [x] 5.2 Push a branch and open a pull request only after user authorization; verify remote CI separately from local checks.
- [ ] 5.3 Merge, tag, package, or release only after explicit user authorization; verify each publication step separately.
