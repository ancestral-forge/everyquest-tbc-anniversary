## Why

The database audit cannot discover replacement quest IDs outside EveryQuest's own records. Maintainers need a bounded API title index and readable diagnostic commands, with Tab completion that does not interfere with ordinary chat.

## What Changes

- Add explicit `/everyquest api discover <first> <last>` range probing, status/cancel/clear and a separate latest-complete per-character report.
- Collect ID/title pairs and preserve duplicate titles for external comparison; never rewrite quest IDs or history automatically.
- **BREAKING**: replace `audit-api` and the unpublished `apioverlay` command with `api audit` and `api overlay`; do not keep legacy aliases.
- Integrate the existing locally tested overlay without losing its phase-label composition or reset-on-reload behavior.
- Add Tab completion under `/everyquest` only, including diagnostic actions and a numeric range usage hint. With the cursor at the end, completion may clear highlighted text selection (accepted 2026-09-06).
- Document maintainer commands in CONTRIBUTING, not README or player options. Keep the previously agreed developer-only changelog omission.

## Capabilities

### New Capabilities

- `quest-api-discovery`: bounded range discovery and atomic title-report persistence.
- `quest-api-command-interface`: grouped diagnostic commands and scoped chat completion.

### Modified Capabilities

None in the canonical specs. Reconcile command examples in the existing unarchived audit and overlay changes during apply.

## Impact

Options.lua, TOC, new discovery and completion modules, the existing audit, the local overlay candidate, Lua tests and CONTRIBUTING. Add only optional `EveryQuestDBPC.char.questApiDiscovery`; preserve schema version, audit report, quest history and static data. No dependencies, packaging, release or installation contract changes. Automated tests and static checks are required; live Tab coexistence, cache behavior and SavedVariables flushing require a human Anniversary client.

## Non-goals

No complete Blizzard database guarantee, zone enumeration, automatic ID correction, fuzzy matching, external datasets, global chat-handler replacement, player UI, background login scans, commits, publication or installation without separate authorization.
