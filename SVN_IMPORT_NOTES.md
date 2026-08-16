# EveryQuest Provenance Notes

Reference information for the original EveryQuest package and the current TBC
Anniversary version.

## Original Package

- SVN tag: `https://repos.wowace.com/wow/everyquest/tags/release-5`
- Tag creation revision: `r16`
- Tag source: `/trunk:15`
- Tag message: `Release 5; Should work good again`
- Tag date: `2008-10-06 11:43:16 +0400`
- Main TOC interface: `20400`
- CurseForge file: `EveryQuest-release-5.zip`
- CurseForge file id: `219312`
- CurseForge supported game version: `2.4.3`

## Current Package

- Addon title: `EveryQuest TBC Anniversary`
- Maintainer: `Ancestral Forge`
- Target game version: WoW Anniversary `2.5.6.69110`
- TOC interface: `20506`
- Runtime compatibility target: TBC Anniversary only
- License: `GPL-2.0-only`

## Modernization Summary

- Removed obsolete Ace2-era dependencies and compatibility shims
- Removed `embeds.xml`
- Removed unused `modules.xml`
- Replaced legacy addon loading with `C_AddOns`
- Replaced legacy quest checks with `C_QuestLog`
- Uses native saved variables, slash commands, and event handling
- Uses Blizzard `UIDropDownMenu` and `SOUNDKIT`

## Attribution

EveryQuest was originally created by kandarz. This TBC Anniversary version is
maintained and published under the Ancestral Forge label.
