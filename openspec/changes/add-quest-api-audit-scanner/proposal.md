## Why

EveryQuest can currently rescan only the player's active quest log; it cannot determine which quest records in its static database are no longer exposed by the TBC Anniversary quest API. Maintainers need a reproducible in-client audit before changing quest data, especially while content such as Sunwell may be present in client data but not yet unlocked on realms.

## What Changes

- Add an explicit, dormant maintainer command that audits every unique quest ID in the shipped EveryQuest data against the Anniversary `C_QuestLog.GetQuestInfo` API.
- Load all EveryQuest data modules read-only for the audit, without changing quest history, completion state, filters, or UI state.
- Run the audit incrementally, wait for a bounded cache warm-up interval before retrying unavailable IDs, expose progress/cancel/status/clear controls, and distinguish unavailable IDs from probe errors or incomplete module loading.
- Preserve only the latest complete compact report in an additive per-character SavedVariables field, including client/build/interface/locale metadata; cancelled or incomplete runs do not replace it.
- Add deterministic Lua tests for collection, batching, retries, failures, cancellation, persistence, clearing, and history non-mutation.
- Document the command and result-interpretation workflow in `CONTRIBUTING.md`; do not advertise it as a normal player feature in `README.md` or add an options-panel control.
- Treat audit output as evidence for maintainer review, never as authority to hide or delete quest records automatically.

## Capabilities

### New Capabilities

- `quest-api-audit`: Defines the maintainer-only, read-only database audit, its lifecycle and report contract, and safe interpretation of unavailable quest IDs.

### Modified Capabilities

None.

## Impact

- Addon modules: a new `EveryQuest/QuestApiAudit.lua`, `EveryQuest/EveryQuest.toc`, and the existing slash-command routing in `EveryQuest/Options.lua`.
- Data modules: all ten load-on-demand `EveryQuest_*` quest-data addons are inspected but not modified by the scanner.
- SavedVariables: `EveryQuestDBPC.char.questApiAudit` becomes an optional additive field; the existing schema version and quest-history records remain unchanged.
- Documentation and validation: `CONTRIBUTING.md`, a new `tools/test-quest-api-audit.lua`, the OpenSpec validation command, and the required `tools/verify-addon.sh` gate.
- Packaging: the scanner ships in the normal addon package; release layout, dependencies, platform publishing, installation, and backup behavior do not change.
- Client behavior: no automatic scan, UI button, background network access, data hiding, or database mutation. A maintainer must invoke the slash command in a live Interface 20506 client.
- Evidence: static OpenSpec validation and the repository gate can be automated. Completion, cancellation, SavedVariables flushing, and confirmation that history/UI remain unchanged require a human WoW client and remain separately reported.

## Non-goals

- Automatically remove, hide, reclassify, or rewrite quests from an audit result.
- Infer realm content availability, phase eligibility, or quest obtainability solely from API title presence or absence.
- Add Retail/Wrath compatibility, asynchronous quest-data APIs absent from the Anniversary interface, external libraries, a general diagnostics framework, or broad quest-data refactors.
- Change existing quest lifecycle, Blizzard UI ownership, packaging, installation, CI, release, or SavedVariables migration contracts.
