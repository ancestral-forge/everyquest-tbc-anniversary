# SVN Import Notes

EveryQuest release package imported from the original TBC-era release and
modernized for WoW Anniversary.

- SVN tag: `https://repos.wowace.com/wow/everyquest/tags/release-5`
- Tag creation revision: `r16`
- Tag source: `/trunk:15`
- Tag message: `Release 5; Should work good again`
- Tag date: `2008-10-06 11:43:16 +0400`
- Main TOC interface: `20400`
- CurseForge file: `EveryQuest-release-5.zip`
- CurseForge file id: `219312`
- CurseForge supported game version: `2.4.3`

The direct SVN export currently times out on large blobs from the WowAce
repository, so the initial import used the official CurseForge/WowAce release
zip generated from the same SVN tag.

The current package targets WoW Anniversary `2.5.6.69110` / TOC interface
`20506` directly. Ace2, Deformat, Dewdrop, Quixote, `embeds.xml`, and the
Classic compatibility shim have been removed; runtime code now uses the
Anniversary APIs directly, including `C_AddOns`, `C_QuestLog`, native slash
commands, native saved variables, `UIDropDownMenu`, and `SOUNDKIT`.
