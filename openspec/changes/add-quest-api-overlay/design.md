## Context

See proposal.md for motivation. The overlay was designed independently of the audit scanner, using the existing phase labels and QuestStore. The audit scanner is now merged in main. Publication includes this overlay together with add-api-discovery-and-completion, which groups the diagnostic commands; the overlay still does not depend on either scanner's state or persistent reports.

## Goals / Non-Goals

Use the existing row render boundary and slash dispatcher. Do not load all data modules, persist results or modify Blizzard UI ownership.

## Decisions

- Add QuestApiOverlay.lua before Options.lua in the TOC. Expose a toggle and marker getter on EveryQuest; keep all state local to the module.
- Probe C_QuestLog.GetQuestInfo only when an enabled row first renders. For empty results, warm the Classic cache via C_QuestLog.GetQuestObjectives and retry GetQuestInfo once after 10 seconds. This follows the scanner's bounded warmup approach and avoids depending on retail-only quest-data events.
- Use one OnUpdate frame only while pending IDs exist. Deduplicate by ID and cache resolved, missing and error results until disabled. Stop the script and clear state on disable, preventing late work from repainting the list. Aggregate completed retries into one redraw per update.
- Errors remain separate from missing titles and emit at most one diagnostic warning per enable cycle. Missing required APIs prevent enabling.
- Insert the marker before getQuestPhaseLabel at UpdateButton. Tests exercise actual row composition as well as the asynchronous state machine.
- A complete database audit and a shared scanner refactor were rejected as unnecessary dependencies for this narrow command.

## Risks / Trade-offs

- Slow data can remain unresolved after 10 seconds: `[?]` is diagnostic only; toggle off/on to refresh.
- Results are a session snapshot: no continuous polling once a quest has a result.
- Browsing many rows accumulates per-ID state until disabled; only visited rows are queued.

## Migration Plan

No migration. Validate Lua tests and the full repository gate. Installation requires authorization and parity; human testing covers toggling during pending work, scroll/zone transitions and phase/status composition. Roll back by removing the command/module integration. Do not archive before required live evidence.
