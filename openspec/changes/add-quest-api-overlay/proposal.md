## Why

Maintainers need to spot quests whose titles the client API does not currently resolve while browsing EveryQuest. A temporary marker makes this visible without confusing missing API data with quest availability.

## What Changes

- Toggle a session-only diagnostic overlay with `/everyquest api overlay`.
- Check rendered quest IDs, request uncached data and retry after a bounded wait before showing `[level/type][?][Phase N] Title`.
- Disable immediately on the next invocation; start fresh on re-enabling and after reload.
- Document the command in CONTRIBUTING.md; omit README and changelog per the user's explicit developer-feature decision.

## Capabilities

### New Capabilities

- `quest-api-overlay`: Opt-in API title diagnostics on rendered rows.

### Modified Capabilities

None.

## Impact

EveryQuest row formatting, slash dispatch and a small diagnostic module loaded from the TOC. No SavedVariables, static quest data, dependency, packaging-layout or status changes. Lua 5.1 regression tests and the repository gate are required; installation parity and live client verification remain separate pending steps.

## Non-goals

Full database audits, persisted reports, automatic realm phase detection, new statuses/colors/tooltips, player options and broad scanner or QuestStore refactoring.
