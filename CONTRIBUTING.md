# Contributing

EveryQuest TBC Anniversary targets the WoW TBC Anniversary client only. Keep
changes narrow, traceable, and aligned with that runtime.

## Quick Contribution Path

Human contributors do not need AI tooling, OpenSpec, or a separate worktree:

1. Create a normal branch in your clone or fork.
2. Make one focused change with reviewable rationale.
3. Run `tools/verify-addon.sh` when the local toolchain is available. If it is
   not, open the pull request and let the required CI gate run the same checks.
4. Open a pull request using the checklist below.

Do not claim a local or in-game check that was not run. A missing local toolchain
is not, by itself, a reason to avoid submitting a contribution.

## Runtime Target

- Target WoW Anniversary `2.5.6.69110` / TOC interface `20506`.
- Write Lua for the client's Lua 5.1 runtime.
- Do not add compatibility branches for older WoW clients unless the project
  explicitly changes scope.
- Preserve original EveryQuest provenance separately from current runtime
  support. Keep `kandarz` attribution and GPL-2.0-only licensing intact.

## Code Changes

- Prefer native Anniversary APIs and events over old Ace-era abstractions.
- Keep Blizzard-owned UI behavior owned by Blizzard; the addon should observe
  and record state instead of replacing secure quest UI handlers.
- Avoid broad refactors when a small, local fix is enough.
- Do not introduce external libraries or generated data without clear
  provenance and licensing.
- For quest data changes, keep the source and mapping rationale reviewable.

## Local Checks

Run the complete local validation gate before publishing changes:

```sh
tools/verify-addon.sh
```

The gate runs Luacheck, parses addon Lua with Lua 5.1, rejects common Lua 5.2+
standard-library usage, parses XML, verifies TOC metadata and file references,
checks repository whitespace, and runs the checked-in Lua regression tests.

Static checks prove syntax and file hygiene only. They do not prove in-game
behavior.

## Maintainer Quest API Audit

EveryQuest ships a dormant in-client scanner for comparing the unique quest IDs
in all ten static data modules with the current Anniversary quest-title API. It
does not run automatically and is intentionally absent from the player help,
options, and README.

Run it only in a TBC Anniversary client:

```text
/everyquest audit-api
/everyquest audit-api status
/everyquest audit-api cancel
/everyquest audit-api clear
```

The first command loads each enabled EveryQuest data module read-only and probes
the resulting IDs in bounded batches. After pass 1 it waits ten seconds without
probing so the client quest cache can warm, then retries only IDs with no title.
`status` prints the current pass and counts, or the remaining warm-up time and
retry-candidate count. `cancel` stops future probes, including during warm-up,
without replacing the last complete report. `clear` removes only the saved audit
report and is refused while a scan is active. Loaded data modules stay resident
until `/reload`, which also reclaims their session memory.

A completed scan stores `EveryQuestDBPC.char.questApiAudit` with
`formatVersion`, `startedAt`, `completedAt`, `addonVersion`, `clientVersion`,
`clientBuild`, `interface`, `locale`, the four result counts (`total`,
`available`, `unavailable`, and `errors`), sorted `unavailableIds`, and sorted
`probeErrors` entries containing an ID and concise reason. Use `/reload` or log
out to flush the report, then inspect the per-character file at
`WTF/Account/<ACCOUNT>/<REALM>/<CHARACTER>/SavedVariables/EveryQuest.lua`.

Treat the report as evidence, not as quest truth. API title presence does not
prove that a quest is available or obtainable on the realm, and a missing title
does not justify automatically hiding or deleting a database record. Client
version `2.5.6` is also not a content-phase signal: client metadata may include
quests from a later unlock.

Classify unavailable candidates before changing data:

- `phase-pending`: keep the record and rerun after the relevant content unlock
  or client-build change;
- `legacy/retired`: require an authoritative provenance source and a live-client
  recheck;
- `seasonal`: rerun while the corresponding event is active and retain the
  source used for the decision;
- `data defect`: make a focused, reviewable correction only after provenance and
  live behavior agree.

In particular, keep Sunwell Plateau, Isle of Quel'Danas, and Magisters' Terrace
candidates phase-pending until that Anniversary phase opens, then rerun the
audit. Automated tests, static checks, packaging, and install parity remain
separate from live API evidence.

The reusable linter workflow runs Luacheck and the Lua 5.1 compatibility check
for main pushes, pull requests, manual dispatches, and releases. The release
workflow must depend on this linter gate before packaging.

## In-Game Verification

For runtime or UI changes, test in the TBC Anniversary client with script
errors enabled:

```text
/console scriptErrors 1
/reload
```

Use the actual affected gameplay path when possible. For quest lifecycle work,
that means testing the relevant accept, complete, abandon, fail, and turn-in
flow rather than relying only on `/reload`.

When installing a checkout into the client, verify repository-to-install parity
with file comparisons. Do not treat a clean install comparison as gameplay
proof.

## Releases

- Update `CHANGELOG.md` under `[Unreleased]` in the same pull request as each
  user-visible change, including bug fixes. Describe the actual player-facing
  effect; do not defer the entry to release preparation. Purely internal
  refactors do not require an entry. OpenSpec checkpoint scope must follow this
  rule even when version bumps and release actions are out of scope.
- Keep `EveryQuest/EveryQuest.toc` versions aligned across addon modules.
- GitHub releases are built from tags named `v<TOC version>`, for example
  `v2026.3.1`.
- Release archives are named `EveryQuest-TBC-Anniversary-<version>.zip`.
- The release workflow packages only the top-level `EveryQuest*` addon
  directories.
- Release archives should not include repository docs, workflow files, or
  branding assets unless the packaging contract intentionally changes.
- `tools/package-release.sh` is the shared packaging contract for GitHub and
  GitLab. Keep its output deterministic so both platforms produce the same
  archive from the same tag.
- `dist/release-notes.md`, generated from the current `CHANGELOG.md` version
  section, is the release changelog for GitHub, CurseForge, Wago, and
  WoWInterface. The packaging script appends release and full-changelog links
  to that generated file. Do not add platform-specific changelog files, and do
  not add release links to `CHANGELOG.md`.
- CurseForge, Wago, and WoWInterface uploads use the BigWigsMods packager in
  upload-only mode after `tools/package-release.sh` has created the archive.
  Keep the external platform uploads pointed at the existing `dist` ZIP rather
  than creating a second archive in the release workflow.
- CurseForge and Wago release labels use `EveryQuest TBC <version>`;
  WoWInterface receives a BigWigs-generated BBCode changelog converted from the
  generated Markdown release notes.
- Configure external publishing with repository variables
  `CURSEFORGE_PROJECT_ID`, `WAGO_PROJECT_ID`, and `WOWINTERFACE_ADDON_ID`, plus
  repository secrets `CURSEFORGE_API_TOKEN`, `WAGO_API_TOKEN`, and
  `WOWINTERFACE_API_TOKEN`. Leave both the ID and token empty to skip a
  platform; setting only one of the pair fails the release.
- `README.md` remains the canonical addon description. The release workflow
  does not synchronize long project descriptions on CurseForge, Wago, or
  WoWInterface; update those platform descriptions manually if they need to
  change.
- GitHub is the canonical repository. GitLab receives branches and tags through
  a write-enabled project deploy key and independently publishes backup
  releases from `v<TOC version>` tags.
- Mirror automation must not force-push or propagate deletions. GitLab is a
  backup and should preserve refs and releases if the GitHub source is removed
  or rewritten accidentally.

## Pull Requests

Include:

- what changed;
- which client/runtime path was affected;
- which checks were run;
- which in-game behavior was tested, or why live verification was not done.

## Maintainer, AI, and OpenSpec Workflow

Repository-aware agents must follow `AGENTS.md` and the project-local
`everyquest-addon-development` skill. These AI-specific rules do not apply to a
human contributor's local Git workflow.

Before merge, maintainers capture high-risk or durable contract changes in
OpenSpec. These include SavedVariables migrations, quest lifecycle or Blizzard
UI ownership, architecture and dependencies, CI and validation contracts,
packaging, installation, backup, and release behavior. A contributor can supply
the intent through an issue or pull request; installing or invoking OpenSpec is
not a submission requirement.

Ordinary focused bug fixes, small features, documentation, localization, and
reviewable quest-data corrections can use the issue or pull-request description
as their planning record when they do not change those durable contracts.
