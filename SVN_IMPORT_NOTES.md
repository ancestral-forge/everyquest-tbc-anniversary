# SVN Import Notes

TBC-compatible EveryQuest release package.

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
repository, so this import uses the official CurseForge/WowAce release zip that
was generated from the same SVN tag. The contents are the packaged installable
layout, including embedded Ace2, Deformat, Dewdrop, and Quixote libraries and
the moved `EveryQuest_*` module addon folders.

The follow-up Anniversary compatibility patch targets WoW Anniversary
`2.5.6.69110` / TOC interface `20506`. It keeps the packaged installable
layout, disables the stale source-layout `modules.xml` load from the main TOC,
adds `C_AddOns` compatibility shims for embedded Ace2 libraries, and updates
old XML script globals (`this`/`arg1`) used by EveryQuest's own frame XML.
