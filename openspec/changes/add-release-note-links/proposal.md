# Add Generated Release Note Links

## Why

Platform release notes should include direct release and changelog links, but
the canonical `CHANGELOG.md` should stay limited to release history content.
The previous manual approach put links into `CHANGELOG.md` so they could flow
into `dist/release-notes.md`, which polluted the canonical changelog.

CurseForge also displays the uploaded file using the BigWigs `archive_label`
metadata. The workflow must pass the ZIP filename there, not just the version.

## What Changes

- Append release and full-changelog links while generating
  `dist/release-notes.md`.
- Keep those generated links out of `CHANGELOG.md`.
- Pass `EveryQuest TBC <version>` as the BigWigs `archive_label` so CurseForge
  and Wago display a readable release label.
- Let BigWigs convert the generated Markdown release notes to BBCode for
  WoWInterface.

## Impact

- `CHANGELOG.md` remains canonical and clean.
- GitHub Releases, CurseForge, Wago, and WoWInterface continue reusing the same
  generated release notes.
- The uploaded artifact keeps its `.zip` filename, while CurseForge and Wago use
  `EveryQuest TBC <version>` as their release label.
