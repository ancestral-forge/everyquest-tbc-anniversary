# EveryQuest agent contract

Use the repository-local `everyquest-addon-development` skill for all work in
this repository. Its workflow and evidence rules are mandatory.

Before implementation, inspect the current branch, SHA, worktrees, and dirty
state. Preserve unrelated changes and implement in a separate clean worktree on
a task-named branch based on current `origin/main`. Do not create `codex/`
branches.

Use OpenSpec for any non-trivial behavior, data-contract, architecture, CI,
packaging, installation, or release change. Start with `$openspec-propose`,
implement through `$openspec-apply-change`, and archive only after required
tasks and evidence are complete. A read-only investigation or mechanical typo
may skip OpenSpec only when the agent states why no behavior or acceptance
criteria changes.

Do not mark an OpenSpec task complete from intention or inference. Run its
command or runtime path and retain the checkbox as incomplete when evidence is
unavailable. Static checks, automated tests, package validation, install parity,
live WoW behavior, Git state, remote CI, merge state, and release state are
separate claims.

The required local technical gate is:

```bash
tools/verify-addon.sh
```

Keep code simple and changes narrow. Never commit, push, install into the WoW
client, merge, tag, or publish unless the user request authorizes that action.
