# Quest API research: 6 September 2026

This note preserves the findings from a TBC Anniversary discovery scan and
possible follow-ups. **It does not approve or implement any addon change.**

The problem: EveryQuest lists quests whose titles the client API does not
resolve. We investigated their provenance before deciding whether any should
be labelled, hidden or corrected. A missing title is not proof of a missing
quest; a returned title is not proof that a quest can be obtained.

## Evidence snapshot

- Client: **2.5.6, build 69546**, Interface 20506, enUS.
- Discovery: IDs **1–100000**, 6442 titles, 93558 missing titles, 0 exceptions.
- EveryQuest: **6176** unique IDs; 5967 returned titles, **209** did not.
- The previous saved audit had 222 missing IDs. Discovery resolved 13 of them,
  with no new misses. The methods differ, so this is not proof of a cache bug.
- 475 returned IDs are outside EveryQuest; they include test/unused entries and
  were not individually researched except for the related candidates below.
- 190 same-ID titles differ as exact strings, including punctuation/spacing;
  these are not automatically incorrect IDs.

The scan ran from 13:55:35 to 14:12:35 UTC using a local experimental discovery
implementation on top of `cf4c898`. **That implementation is not part of this
documentation PR.** It warms missing quest data and retries after a bounded
wait; slow or unavailable data can still remain unresolved.

[Scan metadata](scan-summary.json) and [all 209 individual findings](findings.tsv)
are retained without raw SavedVariables, account/character names, local paths,
chat or screenshots. The detailed analyst notes in the TSV remain in Russian;
quest titles and column names are English.

## Findings

| Classification | IDs | Interpretation |
| --- | ---: | --- |
| Phase 4/5 content | 44 | 9 Phase 4, 30 ordinary Phase 5, 5 Phase 5 paladin-chain variants |
| Historical mechanics / temporary events | 78 | 33 AQ-opening, 12 Scourge Invasion, 19 old PvP, 14 old mount exchanges |
| Holiday quests and versions | 31 | 24 ordinary seasonal quests, 7 historical/versioned Brewfest variants |
| Unused beta candidate | 1 | 10059, Dealing With Zeth'Gor |
| API absence still unexplained | 55 | 24 Dungeon Set 2, 13 ZG/Naxx/Atiesh, 11 package/reward variants, 6 other quests, 1 hunter introduction |

These are **provenance classifications, not 209 proven causes of API failure**.
Confidence in the TSV refers to classification, not live NPC availability.
The mount-exchange group has only medium confidence in present unavailability;
the seven Brewfest variants also need version-specific verification.

### Matching titles do not establish replacement IDs

53 missing IDs have exact-title matches in discovery. Nine have a match outside
EveryQuest, producing 11 candidate pairs. Inspection found different branches,
level variants and factions rather than a basis for automatic renumbering.

- **Paladin:** 9722/9723/9725/9735/9736 correspond to alternative Liadrin steps
  64140/64141/64142/64143/64144. NPCs, objectives and reciprocal exclusions
  support the mapping. The missing introduction 64139 also returned a title.
  A future addition could preserve both branches and their shared finish 9737;
  replacing old IDs or substituting 64145 for the finish is not justified.
  [Branch definitions][paladin].
- **WSG:** 7872/7873 → 8291 and 7875 → 8294 are old variants with different
  minimum levels, not newly assigned IDs. [Historical PvP entries][pvp].
- **Brewfest:** 12421 → 12278 crosses Horde/Alliance and starting items.
  The related Horde 12306 is already in EveryQuest; the event model treats
  12421 differently by expansion. [Event definitions][brewfest].

### Historical does not mean every related quest disappeared

Dungeon Set 2 and ZG removal conditions in Questie start with Cataclysm; Atiesh
starts with Wrath. Those conditions do not establish removal in TBC.
[Dungeon Set 2][set2], [ZG][zg], [Atiesh][atiesh].

Blizzard's Anniversary AQ description explicitly allows **8745 Treasure of the
Timeless One after the Bang a Gong window**, provided its own prerequisite is
complete. The whole scepter chain must not be hidden as an expired event.
[Official AQ description][aq] (Vanilla Anniversary, not TBC Phase 5).

10059 has a BETA title, no quest-giver/finisher in the referenced database, and
an unconditional TBC exclusion in Questie. This makes it the strongest current
candidate for an explicit unused-entry exclusion, **not an applied correction**.
[Database entry][beta-db], [exclusion][beta-hide].

### API results cannot control phase labels

Across all existing phase-labelled EveryQuest records, Phase 4 has **2 returned
titles / 9 misses** and Phase 5 has **18 / 35**. A title response therefore
does not determine whether the phase has opened.

The tester's context was Hyjal/Black Temple open and Zul'Aman/Sunwell closed.
That is reported context, not an independently verified realm schedule.
Sunwell also has its own island-progression stages that intentionally replace
one daily ID with another; these are not necessarily bad database duplicates.
[Daily-stage overview][sunwell].

## Further thoughts — not a committed implementation plan

For now, retain this evidence and leave addon behavior unchanged. Possible
small follow-ups to discuss independently:

- **Tooltip explanations:** add concise, reviewed phase/event/history notes to
  the existing hover tooltip, including a static-title fallback when API data
  is empty. Keep content provenance separate from character status and colors.
- **Selective hiding:** consider only explicitly corroborated unused entries
  first, such as 10059. A later opt-in historical filter would need consistent
  list/scroll counts and must preserve actual completion history.
- **New labels:** whether Season/Legacy labels add useful information or just
  shorten visible titles remains an open UX question.
- **Data correction:** review adding the Liadrin branch separately, preserving
  old IDs and saved completion. Do not transfer history by matching names.
- **Targeted evidence:** revisit the 55 unexplained cases by quest family and
  the uncertain holiday variants during the relevant event, using appropriate
  characters, prerequisites and NPC/item interactions.

No general framework, new feature flags, hiding rules, tooltip changes or
SavedVariables migration are proposed for implementation in this PR. Any later
behavioral change needs its own scoped plan and appropriate tests/live evidence.

## Sources and limits

The TSV records a source for every ID, a confidence level, related IDs and a
possible next check. **Related IDs and title candidates are not replacements.**
A dash in the final column means no exact-title candidate; `* (нет в EQ)`
marks a candidate absent from EveryQuest.

Questie references are pinned to
`94e2a1420ba989c344508f1b08e6767a8a3fa5a3`. The installed base TBC database
matched that commit; relevant corrections and blacklist sections were checked
against pinned upstream separately. Questie is a primary source for **its own
data model**, not an official Blizzard availability service. Historical
references and expansion-specific conditions must not be read as live proof.

This publishes analysis and factual ID relationships with source attribution,
not copied Questie runtime code or quest-description text. Existing EveryQuest
quest-data attribution and licensing remain unchanged.

The inventory was checked for **209 unique IDs, no omitted rows, and a finding,
source and next-check note for each**. No per-quest live NPC verification was
performed. No game files, quest records, status logic, saved history, OpenSpec
acceptance checkboxes, packaging behavior or player-facing changelog are changed.

[paladin]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/Corrections/tbcQuestFixes.lua#L7931
[pvp]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/Corrections/QuestieQuestBlacklist.lua#L757
[brewfest]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/Corrections/Holidays/quests/Brewfest.lua#L35
[set2]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/Corrections/QuestieQuestBlacklist.lua#L4799
[zg]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/Corrections/QuestieQuestBlacklist.lua#L4553
[atiesh]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/Corrections/QuestieQuestBlacklist.lua#L5021
[aq]: https://worldofwarcraft.blizzard.com/en-us/news/24213950
[beta-db]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/TBC/tbcQuestDB.lua#L5150
[beta-hide]: https://github.com/Questie/Questie/blob/94e2a1420ba989c344508f1b08e6767a8a3fa5a3/Database/Corrections/QuestieQuestBlacklist.lua#L1105
[sunwell]: https://warcraft.wiki.gg/wiki/Template%3AShattered_Sun_Offensive_Dailies
