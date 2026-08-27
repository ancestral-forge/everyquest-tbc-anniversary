# Design: BigWigs Upload-Only Publishing

## Context

The repository already owns deterministic packaging in `tools/package-release.sh`.
Replacing that with BigWigsMods packager would change archive byte output even
when the extracted addon contents match, because the packager emits directory
entries that the current ZIP contract does not.

## Decision

Use BigWigsMods packager only as the publishing integration layer.

The release workflow keeps the current package step and GitHub Release step.
After `dist/release.env` identifies the release version and asset, each
configured external platform invokes the pinned BigWigsMods packager action with:

```text
-c -z -u -m .pkgmeta
```

The `-c` and `-z` flags skip BigWigs file copying and ZIP creation. The workflow
passes the existing archive through the packager's `archive`, `archive_name`,
`archive_label`, and `archive_version` environment variables. `.pkgmeta` points
`manual-changelog` at `dist/release-notes.md`, so CurseForge, Wago, and
WoWInterface use the same changelog body as GitHub.

Each platform has its own action step and only receives its own token:

- CurseForge: `vars.CURSEFORGE_PROJECT_ID` and `secrets.CURSEFORGE_API_TOKEN`
- Wago: `vars.WAGO_PROJECT_ID` and `secrets.WAGO_API_TOKEN`
- WoWInterface: `vars.WOWINTERFACE_ADDON_ID` and
  `secrets.WOWINTERFACE_API_TOKEN`

The BigWigs action is pinned to a commit SHA instead of a mutable branch because
the action receives publishing credentials.

## Risks

- BigWigs upload-only reuse depends on `release.sh` accepting an existing
  `archive` environment variable when ZIP creation is skipped. This behavior is
  verified locally and protected by pinning the action revision.
- BigWigs does not synchronize long project descriptions from `README.md` for
  these platforms. `README.md` remains canonical in the repository; platform
  descriptions must be updated manually when needed.
