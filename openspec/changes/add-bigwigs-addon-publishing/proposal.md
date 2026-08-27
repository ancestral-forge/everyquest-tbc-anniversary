# Add BigWigs Addon Publishing

## Why

Tagged releases currently publish the deterministic addon archive to GitHub
Releases only. The same tagged release should also publish to CurseForge, Wago,
and WoWInterface without introducing separate release artifacts or changelog
sources.

## What Changes

- Keep `tools/package-release.sh` as the only release archive generator.
- Reuse `dist/release-notes.md`, generated from the current `CHANGELOG.md`
  section, for all platform release changelogs.
- Add a minimal `.pkgmeta` so BigWigsMods packager can use the generated release
  notes as a manual changelog and discover the addon TOC.
- Add upload-only BigWigsMods packager steps for CurseForge, Wago, and
  WoWInterface after the existing GitHub Release publication.
- Document the required GitHub repository variables, secrets, and platform
  description synchronization limitation.

## Impact

- A `v<TOC version>` tag still runs validation, packages the existing
  deterministic ZIP, and creates or updates the GitHub Release.
- Configured external platforms receive the same ZIP and release notes.
- Missing external platform configuration skips that platform; partial ID/token
  configuration fails the release with an explicit error.
