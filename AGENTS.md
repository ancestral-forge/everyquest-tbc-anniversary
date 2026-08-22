# EveryQuest agent contract

This file governs AI agents working in this repository. It does not impose
AI-specific tools or worktree practices on human contributors; the human path
is documented in `CONTRIBUTING.md`.

AI agents must use the repository-local `everyquest-addon-development` skill.
Its workflow and evidence rules are mandatory for agent work.

Before implementation, an AI agent must inspect the current branch, SHA,
worktrees, and dirty state. Preserve unrelated changes and implement in a
separate clean worktree on a task-named branch based on current `origin/main`.
Do not create `codex/` branches.

Use OpenSpec before implementing high-risk or durable contract changes:
SavedVariables schema or migration, quest lifecycle or Blizzard UI ownership,
architecture or dependency boundaries, CI and validation contracts, packaging,
installation, backup, or release behavior. Start with `$openspec-propose`,
implement through `$openspec-apply-change`, and archive only after required
tasks and evidence are complete.

An ordinary focused bug fix, small feature, documentation or localization edit,
or reviewable quest-data correction can use its issue or pull-request
description as the plan when durable contracts and acceptance criteria are
clear. State why OpenSpec is not needed. If implementation exposes an unresolved
product or architectural decision, stop and create or update an OpenSpec change.

Do not mark an OpenSpec task complete from intention or inference. Run its
command or runtime path and retain the checkbox as incomplete when evidence is
unavailable. Static checks, automated tests, package validation, install parity,
live WoW behavior, Git state, remote CI, merge state, and release state are
separate claims.

The required local technical gate for AI implementation is:

```bash
tools/verify-addon.sh
```

Keep code simple and changes narrow. Never commit, push, install into the WoW
client, merge, tag, or publish unless the user request authorizes that action.
