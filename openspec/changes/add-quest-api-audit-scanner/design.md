## Context

See `proposal.md` for motivation and `specs/quest-api-audit/spec.md` for the behavior contract. The current `ScanQuestLog` scans only active quest-log entries and mutates character history. Static quest records live in ten load-on-demand addons, while `LoadQuestData(group)` also hydrates history and synchronizes completed flags, so neither path is a safe primitive for a database-wide read-only audit.

The current TBC Anniversary Interface 20506 API exposes `C_QuestLog.GetQuestInfo(questID)`, which may return no value. It does not expose the Retail asynchronous `RequestLoadQuestByID` / `QUEST_DATA_LOAD_RESULT` contract. The addon uses Lua 5.1, a shared event frame, and SavedVariables schema version 1.

## Goals / Non-Goals

**Goals:**

- Keep the audit dormant, deterministic, cancellable, and independently testable.
- Preserve quest history and existing UI/event ownership while reading every shipped data module.
- Produce a compact report whose client context and failure categories are sufficient for later comparison and triage.

**Non-Goals:**

- Build a generalized job scheduler, data browser, report UI, phase detector, or compatibility abstraction.
- Infer server unlock state or turn an API response directly into a quest-data edit.
- Persist every positive probe or duplicate static titles already present in the database.

## Decisions

### 1. Ship one isolated scanner module and a dormant slash-command route

Add `EveryQuest/QuestApiAudit.lua` after `Everyquest.xml` in the main TOC and route the exact `api audit` command plus `status`, `cancel`, and `clear` subcommands from `Options.lua`. The scanner attaches its public command entry point to `EveryQuest`, but keeps run state private to the module. It is intentionally absent from the normal `/everyquest help` string and options UI; `CONTRIBUTING.md` is the discoverability surface for maintainers.

This keeps the capability available in a real client without maintaining a separate addon or development build. Rejected alternatives are an automatic login scan, a player-facing options button, and a separate companion addon; each adds lifecycle, UX, packaging, or synchronization cost that the maintenance task does not need.

### 2. Load LOD data through a scanner-local read-only loader

The module owns the canonical ten group/addon pairs and checks `C_AddOns.IsAddOnLoaded`, `DoesAddOnExist`, and `GetAddOnEnableState` before calling `C_AddOns.LoadAddOn`. It never calls `EveryQuest:LoadQuestData`, because that path intentionally mutates history. A missing, disabled, failed, or empty module aborts collection before probing; the scanner never enables addons on the player's behalf.

After all modules publish their `EveryQuestData[group]` tables, a pure collector walks zone and quest tables, accepts positive numeric IDs, de-duplicates them, and sorts ascending. This pure boundary makes data traversal testable with fixtures and avoids refactoring existing UI data access. Rejected alternative: changing `LoadQuestData` to accept a read-only flag, which would widen a mature quest lifecycle path merely for diagnostics.

### 3. Use a private frame-driven state machine with no events

The scanner creates one private frame only when its module loads and assigns an `OnUpdate` script while a run is active. Each probing update processes a small fixed batch, then yields. Run state records the phase (`collect`, `probe`, `warmup`, or `retry`), ordered IDs, current index, counts, retry IDs, errors, bounded warm-up time, cancellation flag, and immutable run metadata.

No Blizzard event is needed because Interface 20506 provides a synchronous, may-return-nothing title probe. The private frame avoids registering or replacing handlers on EveryQuest's shared event frame and is detached on completion, failure, or cancellation. During warm-up it accumulates the frame callback's `elapsed` value and issues no probes. This preserves Blizzard UI ownership, keeps status and cancellation on the same state machine, and avoids inventing unsupported asynchronous event behavior. A timer chain was rejected because a single private frame has simpler ownership and deterministic unit-test stepping.

### 4. Probe defensively and retry only missing titles

Each API call is wrapped independently so one Lua error cannot abort or misclassify the rest of the database. A non-empty string is available; nil or an empty string enters an ordered retry list; an exception becomes an error entry. After the first pass, the state machine waits for ten seconds of accumulated frame-update time without probing, then begins a second bounded pass over only retry candidates. Status exposes the remaining warm-up time and cancellation stops it like any other active phase. A second missing result becomes unavailable; an error remains an error.

Live client evidence showed why the pause is necessary: a cold-cache run on client 2.5.6.69546 reported 4,383 unavailable IDs, while a later run after reload reported only 264, with all 264 contained in the first result. The delayed two-pass design gives requests from the first pass bounded time to populate the client cache without pretending that the API has a documented cache-loading event. Rejected alternatives are an immediate retry, which reproduced thousands of transient false negatives, a single pass, which is unnecessarily brittle, and unbounded repeated retries, which cannot establish stronger truth and makes completion unpredictable.

### 5. Persist one optional compact report atomically

Capture metadata at start using addon metadata, `GetBuildInfo`, `select(4, GetBuildInfo())` or the available interface value, `GetLocale`, and timestamps. Build the final report in run-local memory, validate its counts, then assign it once to `EveryQuest.db.char.questApiAudit` only after both passes finish. Store a report format version, metadata, counts, sorted unavailable IDs, and compact error records; store only the available count, not thousands of positive IDs or duplicate static titles.

Cancellation and failures destroy only transient state. `clear` deletes only the optional audit field and is refused during a run. Because the field is additive beneath the existing character root, schema version 1 remains unchanged and no migration is needed. Rollback consists of removing the new Lua/TOC/command/docs/tests; older compatible code ignores the unknown field, and maintainers may clear it before rollback if desired.

Rejected alternatives are account-wide storage, which loses per-client-character provenance, and chat-only output, which is too large and cannot be compared reliably after reload.

### 6. Keep interpretation outside runtime policy

Runtime reports counts and IDs but does not label quests as removed, future, seasonal, or invalid. `CONTRIBUTING.md` defines the review workflow: flush SavedVariables with logout or `/reload`, retain version/build/interface/locale, classify candidates outside the addon, defer phase-pending content, rerun after phase or build changes, and require a provenance source plus live confirmation before a quest-data correction.

This avoids hard-coding a realm roadmap into the addon and prevents client version `2.5.6` from being mistaken for a content-phase signal. Rejected alternative: phase-specific ignore lists or automatic hiding, which would become stale and conflate metadata availability with gameplay availability.

### 7. Test through injected WoW API boundaries

Keep collection and state-machine transitions callable with module-local dependencies that tests can stub: addon loading, title lookup, elapsed frame stepping, clock/build/locale metadata, and printing. `tools/test-quest-api-audit.lua` will load the production module in a minimal fake WoW environment and assert deterministic collection, module failures, batching, a probe-free ten-second warm-up, warm-up status and cancellation, retry classification, errors, concurrency, persistence, clearing, and history non-mutation. The existing verifier discovers `tools/test-*.lua`, so no new test runner or dependency is introduced.

Static tests can prove state transitions and mutation boundaries; only a real Anniversary client can prove the live API responses, frame behavior, and SavedVariables flush. Those evidence layers remain separate in the task list and completion report.

## Risks / Trade-offs

- [The API may omit valid, future, retired, seasonal, or temporarily unavailable quest metadata] → Preserve raw unavailable IDs with build context, make no runtime data decision, and require later provenance plus live rechecks.
- [Loading all ten data addons increases memory for the session] → Run only on explicit command, reuse the shipped tables, avoid copied indexes, and document that a reload can reclaim session state.
- [Even bounded probing can create a visible hitch on slower clients] → Use a conservative fixed batch and report progress; tune the batch only from live-client evidence without changing the result contract.
- [The fixed warm-up may still be shorter than cache population on a slow client] → Keep results evidence-only, retain client/build metadata, and require provenance plus a later live recheck rather than adding unbounded retries.
- [An API exception could leave the frame active] → Wrap individual probes, centralize terminal cleanup, and test completion, failure, and cancellation paths.
- [A compact report omits available-ID detail] → Available IDs can be reconstructed from the same shipped database; preserving only anomaly IDs keeps SavedVariables small and reviewable.
- [LOD modules remain loaded after cancellation] → WoW cannot unload addons during a session; document this normal consequence and avoid any additional mutations.

## Migration Plan

1. Add the scanner module, command routing, tests, and maintainer documentation without changing schema version 1.
2. Run strict OpenSpec validation and `tools/verify-addon.sh` in the isolated worktree.
3. In a human-operated TBC Anniversary client, enable script errors, start and cancel one audit including during warm-up, rerun it to completion, inspect probe and warm-up status, reload to flush SavedVariables, and verify the stored metadata/counts and unchanged history/UI behavior.
4. If rollback is needed, remove the scanner file, TOC entry, command route, tests, and documentation. The optional stored report can remain ignored or be removed with `api audit clear` before rollback.

No package publication, client installation, commit, push, merge, tag, or release is part of implementation unless separately authorized.
