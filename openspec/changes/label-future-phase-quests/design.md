## Context

See `proposal.md` for motivation and `specs/future-phase-labels/spec.md` for the observable contract. Quest list rows are formatted in `EveryQuest:UpdateButton`; status resolution and color selection are already separate from the title text. Static quest records use compact keys and can appear in more than one zone. The quest API scanner deliberately cannot determine realm phase availability, so this feature needs reviewed shipped metadata rather than runtime inference.

The current release is for TBC Anniversary Phase 3. Zul'Aman belongs to Phase 4, while the Shattered Sun Offensive, Isle of Quel'Danas, Magisters' Terrace, and Sunwell content belongs to Phase 5. The requested UI is a plain bracketed marker between the existing level/type prefix and title, with no overlay or tooltip.

## Goals / Non-Goals

**Goals:**

- Keep phase classification explicit, reviewable, and close to the existing quest data.
- Allow a release patch to retire Phase 4 and Phase 5 labels independently.
- Compose the phase marker with the existing level/type prefix, title, and status formatter without changing status or color logic.
- Make the data set and formatter behavior deterministic under Lua tests.

**Non-Goals:**

- Introduce automatic phase discovery, a player preference, or a generalized content-release framework.
- Reclassify every quest by original Burning Crusade patch number.
- Use scanner unavailability, numeric ID ranges, title keywords, or a zone viewed by the player as phase truth.
- Change quest sorting, tooltips, context menus, Blizzard-owned UI, event ownership, or SavedVariables.

## Decisions

### 1. Store reviewed phase as an additive compact quest field

Use an additive numeric `p` field on each reviewed static quest record. Phase 4 covers every shipped record corroborated as phase-gated in the reviewed Phase 4 set, including the complete Zul'Aman quest set. Phase 5 similarly covers the reviewed Phase 5 set, including the complete shipped Shattered Sun Offensive, Isle of Quel'Danas, Magisters' Terrace, and Sunwell quest sets, relevant class quests, quests stored under other geographic zones, and duplicate appearances of the same quest ID. Before editing, build an inventory by quest ID and verify every duplicate receives the same value.

The source inventory starts from the explicit Zul'Aman (`3805`), Isle of Quel'Danas (`4080`), and Magisters' Terrace (`4095`) buckets, then follows their quest IDs and the clearly named Shattered Sun quest records across the other shipped modules. Record no phase for a candidate that cannot be corroborated. Existing names, IDs, levels, factions, types, daily flags, ordering, and attribution are not rewritten.

For the initial Phase 3 release, corroborate the inventory against the Burning Crusade content-phase corrections shipped by Questie `11.37.1` for Interface `20506`. The intersection with the current EveryQuest database contains 11 Phase 4 quest IDs and 53 Phase 5 quest IDs across Classes, Dungeons, Eastern Kingdoms, Outland, and Raids. The focused test retains the exact reviewed ID sets. This imports no Questie code or descriptive content; it records only the factual phase assignment for EveryQuest's already-attributed quest IDs.

This keeps the phase beside the record it describes and makes future review visible in the data diff. A central runtime quest-ID map was rejected because it would duplicate quest data in an unrelated UI file. Zone-only inference was rejected because the same quest may be shown from another zone, and API/ID/title heuristics were rejected because they do not establish content availability.

### 2. Treat the enabled phase set as a maintainer release flag

Keep a small module-local allowlist with Phase 4 and Phase 5 enabled in the Phase 3 release. It is intentionally not a profile option or SavedVariables field. After Zul'Aman opens, a release patch flips/removes only the Phase 4 entry; after Phase 5 opens, it flips/removes the Phase 5 entry. The `p` metadata may remain as inert provenance.

Independent boolean entries are preferred over one global flag because a single switch would hide the still-useful Phase 5 explanation when Phase 4 opens. A client-version check, date, or current-phase API was rejected because none reliably represents the realm unlock schedule.

### 3. Add one pure phase-marker formatter before status suffixing

Add a small local helper that accepts the quest record and returns `"[" .. L["Phase"] .. " " .. phase .. "]"` only when `p` is a supported numeric phase and that phase's release flag is enabled; otherwise it returns an empty string. Add `Phase` to the existing localization table so localization fallback remains consistent with other labels.

`EveryQuest:UpdateButton` composes `[level/type]`, the phase helper result, a space, and the quest title, then applies the existing Failed/Abandoned status suffix. The resulting order is `[70][Phase 4] Quest (Failed)`. With the phase flag disabled or no reviewed metadata, the original `[70] Quest` spacing is preserved. Status calculation, row colors, sorting keys, quest links, tooltip content, and click handlers are untouched.

Formatting the title at this single render boundary is preferred over mutating stored quest names or decorating button overlays. It naturally refreshes with the existing list redraw path and has no new frame, event, or Blizzard UI ownership.

### 4. Test metadata and rendering independently

Add one Lua 5.1 regression test that loads the production formatter in a minimal environment and checks enabled/disabled flags, Phase 4/5 output, unsupported/unmarked records, localization, and ordering with Failed/Abandoned suffixes. The same test loads the affected data modules to verify the expected phase inventory, allowed phase values, and duplicate-ID consistency.

Automated tests establish deterministic data and formatting behavior. Only a human client can verify that the longer rows fit acceptably and preserve visible status colors and interactions.

## Risks / Trade-offs

- [A quest is assigned to the wrong phase] → Restrict metadata to corroborated content sets, review the full ID inventory, and test duplicate consistency; leave uncertain records unmarked.
- [A phase launches but its marker remains visible] → Keep phase entries as obvious release flags and ship a narrow patch that disables the opened phase.
- [Long titles clip sooner] → Use only the requested short marker and verify representative long Phase 4/5 titles in the live client.
- [Phase metadata is present but inert after launch] → Accept the small additive field as provenance; it does not affect SavedVariables or runtime when its flag is disabled.
- [Future scanner results disagree with metadata visibility] → Treat scanner output and phase labels as separate evidence; neither automatically edits the other.

## Migration Plan

1. Add reviewed `p = 4` and `p = 5` metadata, the two enabled release flags, the localized formatter, and focused tests without changing SavedVariables or schema versions.
2. Run strict OpenSpec validation, focused Lua coverage, and `tools/verify-addon.sh` in the isolated worktree.
3. With separate installation authorization, install the exact candidate and verify repository/install parity.
4. In a human-operated TBC Anniversary client, `/reload`, inspect representative Phase 4 and Phase 5 rows including long and status-bearing titles, and verify text, colors, tooltips, sorting, and clicks.
5. When Phase 4 opens, publish a patch that disables only its release flag; repeat for Phase 5. If the feature must be rolled back earlier, disable both flags or remove the formatter while leaving additive `p` fields harmless.
