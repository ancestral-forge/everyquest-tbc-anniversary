## 1. Preparation

- [x] 1.1 Verify branch, SHA, dirty state and worktree based on current origin/main; inspect runtime spec, scanner and render/command paths.

## 2. Implementation

- [x] 2.1 Implement session toggle, bounded delayed checks, deduplication and error handling; verify focused Lua tests including cancellation and re-enable.
- [x] 2.2 Integrate slash command, TOC and row marker; test actual phase/status composition and disabled behavior.
- [x] 2.3 Document command and cache limitations in CONTRIBUTING.md; verify README/changelog remain unchanged per the explicit user decision.

## 3. Validation

- [x] 3.1 Run tools/verify-addon.sh and focused Lua regression tests; inspect final diff and state.
- [x] 3.2 Run strict change validation and openspec validate --all.

## 4. Client evidence

- [x] 4.1 After installation authorization, install and verify all addon directory pairs with diff -qr.
- [ ] 4.2 In Anniversary, test enabled/disabled/re-enabled overlay, pending cancellation, scrolling, zone changes and phase/status composition after /reload with script errors enabled.

## Live evidence checkpoint (2026-09-06)

The user confirmed that `[?]` markers appeared in the installed Anniversary
client. The complete toggle/cancellation/navigation matrix in task 4.2 has not
been confirmed, so the task remains unchecked. This change is published with
add-api-discovery-and-completion; it is not archived.
