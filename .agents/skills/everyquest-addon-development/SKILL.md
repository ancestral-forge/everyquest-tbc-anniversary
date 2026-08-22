---
name: everyquest-addon-development
description: Plan, implement, review, validate, install, or release changes in the EveryQuest TBC Anniversary addon. Use for any task touching Lua, XML, TOC metadata, quest data, SavedVariables, UI behavior, workflows, packaging, client installation, or release evidence in this repository.
---

# EveryQuest addon development

Keep EveryQuest changes narrow, reviewable, and honest about what was actually
proved. Treat `AGENTS.md`, `CONTRIBUTING.md`, `openspec/config.yaml`, and the
relevant files under `openspec/specs/` as the project contract.

## Establish the work state

1. Run `git worktree list`, `git status --short --branch`, and
   `git log -1 --oneline` before editing.
2. Preserve unrelated changes. For implementation, work in a clean, named
   task branch and separate worktree based on the current `origin/main`.
3. Never invent a `codex/` branch name. Derive a short branch name from the
   issue or requested change.
4. Write or show a compact plan before implementation. Keep commits small when
   the user requests commits; do not commit, push, install, publish, or merge
   unless the request authorizes that action.

## Decide whether OpenSpec is required

Use `$openspec-propose` before code when the request changes addon behavior,
data contracts, architecture, CI gates, packaging, installation, or release
behavior. Update the artifacts when implementation reveals a changed decision.

OpenSpec may be skipped for read-only investigation and a truly mechanical
typo or formatting-only edit. State the reason for the skip. If expected
behavior, acceptance criteria, or validation scope needs judgment, do not skip.

During apply, read every context file reported by OpenSpec. Do not mark a task
complete until its stated command or runtime path has produced evidence.

## Implement within the runtime contract

- Target WoW TBC Anniversary only: Interface `20506`, Lua 5.1.
- Prefer native Anniversary APIs and events over compatibility layers.
- Let Blizzard own secure and reward UI behavior. Observe state instead of
  replacing Blizzard quest handlers.
- Preserve SavedVariables data unless a versioned migration is specified.
- Preserve GPL-2.0-only licensing, original attribution, and data provenance.
- Prefer a local fix over a broad refactor or new dependency.
- Inspect each complete changed function and the final diff before validation.

## Run the project gate

Run the complete local gate from the repository root:

```bash
tools/verify-addon.sh
```

The gate covers Luacheck, Lua 5.1 compatibility, XML parsing, TOC consistency
and file references, repository whitespace, and the checked-in Lua regression
tests. Add a focused regression test when the changed behavior can be exercised
outside the WoW client.

For release work, also run `tools/package-release.sh v<version>` and inspect the
archive contents and checksum. For installation, sync only the `EveryQuest*`
addon directories and prove repository/install parity with `diff -qr`.

## Keep evidence layers separate

Report these states independently:

1. Source inspection and diff review.
2. Static gate results.
3. Automated regression tests.
4. Package/archive verification.
5. Installed-file parity.
6. Live TBC Anniversary behavior after `/reload` and the affected gameplay/UI
   path.
7. Commit, push, PR, remote CI, merge, tag, and release state.

Never use static checks or install parity as proof of live gameplay. If the WoW
client was not exercised, label live verification as pending. For quest
lifecycle changes, test the affected accept, complete, turn-in, abandon, or fail
path with `/console scriptErrors 1`; for UI changes, test the actual geometry and
interaction that changed.

## Finish without silent omissions

- Re-run `git status --short --branch` and inspect the complete diff.
- Re-run `openspec validate --all` for OpenSpec-backed work.
- Keep incomplete or unavailable evidence unchecked in `tasks.md`.
- Summarize changed files, commands and outcomes, live verification, and every
  external delivery state separately.
