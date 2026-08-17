# EveryQuest TBC Anniversary

EveryQuest TBC Anniversary is a maintained version of EveryQuest for WoW TBC
Anniversary. It keeps the original purpose of EveryQuest: tracking quest
history and browsing zone quest lists in game.

This continuation targets the TBC Anniversary client only. The original TBC
release is preserved as provenance and data history, not as a runtime
compatibility target.

Maintained by Ancestral Forge.

## Provenance

EveryQuest was originally created by kandarz and published through WowAce and
CurseForge under the GNU General Public License version 2.

This repository started from the original TBC-era release package:

- WowAce SVN tag: `https://repos.wowace.com/wow/everyquest/tags/release-5`
- CurseForge file: `EveryQuest-release-5.zip`
- CurseForge file ID: `219312`
- Original supported game version: `2.4.3`

See `SVN_IMPORT_NOTES.md` for the import details.
See `CHANGELOG.md` for changes in the Ancestral Forge continuation.

## Current Maintainer

This TBC Anniversary version is maintained and published under the Ancestral
Forge label.

Modernization work in this repository includes:

- Direct support for WoW Anniversary `2.5.6.69110` / TOC interface `20506`
- Removal of obsolete Ace2-era dependencies and compatibility shims
- Native saved-variable handling with a strict Anniversary schema
- Native slash-command handling
- Use of current Anniversary APIs such as `C_AddOns` and `C_QuestLog`
- Runtime fixes for the modern TBC Anniversary client

## Releases

GitHub releases are built from tags named `v<version>`, for example
`v2026.3.1`. The release workflow packages only the addon folders into
`EveryQuest-TBC-Anniversary-<version>.zip`.

## Support

If you like this addon or the work behind it, you can support Ancestral Forge
through Lava. It is completely optional, and every bit is warmly appreciated.

- Support on Lava: https://app.lava.top/ancestral-forge?tabId=donate

No perks, no priority queue, no paid support; just a thank-you.

## Source and Issues

- Source code: https://github.com/ancestral-forge/everyquest-tbc-anniversary
- Issue tracker: https://github.com/ancestral-forge/everyquest-tbc-anniversary/issues

## Credits

- kandarz: original EveryQuest author
- Wowhead: original quest data credit carried from EveryQuest metadata
- bayi: original quest history display credit carried from EveryQuest metadata
- Ancestral Forge: TBC Anniversary modernization and maintenance

## License

EveryQuest TBC Anniversary is distributed under GPL-2.0-only.

This is a continuation of a GPLv2 project, so derivative versions must preserve
the GPLv2 license terms and the original attribution notices. See `COPYING` for
the full license text.
