# Contributing

EveryQuest TBC Anniversary targets the WoW TBC Anniversary client only. Keep
changes narrow, traceable, and aligned with that runtime.

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

- Update `CHANGELOG.md` for user-visible changes.
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

## AI and OpenSpec workflow

Repository-aware agents must follow `AGENTS.md` and the project-local
`everyquest-addon-development` skill. Material behavior, data-contract,
architecture, CI, packaging, installation, and release changes use OpenSpec so
scope, requirements, design decisions, tasks, and evidence remain reviewable.

Start a change with `$openspec-propose`, implement it with
`$openspec-apply-change`, and archive it only after the required tasks and
evidence are complete. Read-only investigation and mechanical typo fixes may
skip a new OpenSpec change when the reason is stated explicitly.
