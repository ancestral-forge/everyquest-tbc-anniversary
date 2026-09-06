## Context

See proposal.md for motivation. Implementation began on quest-api-discovery from main cf4c898, which contains the audit. The reviewed overlay runtime, tests and change artifacts were imported without modifying the original overlay worktree. For publication on 2026-09-06, the combined discovery, completion and overlay changes were transferred into a separate clean quest-api-discovery-pr worktree based on fresh origin/main 1087df0. The original implementation worktrees remain intact.

Anniversary source inspected on 2026-09-06 exposes ChatEdit_CustomTabPressed explicitly for addon completion; its truthy return suppresses normal SecureTabPressed. Source: https://github.com/Gethe/wow-ui-source/blob/classic_anniversary/Interface/AddOns/Blizzard_ChatFrameBase/Shared/ChatFrameEditBox.lua . The branch is moving evidence, not live-client proof; verify the installed client's entry point during acceptance.

## Goals / Non-Goals

Keep the scanner and completion independent of quest history and Blizzard secure quest UI. Avoid a generic job framework, global chat mixin replacement, popup UI, automatic publication, and automatic ID remapping.

## Decisions

### Grouped commands

Parse the api namespace in Options.lua; retain ordinary toggle/debug/help behavior. Route audit, discover and overlay to small modules. Remove old diagnostic spellings, update runtime help strings, tests and unarchived OpenSpec command examples together, preserving dated historical evidence. The overlay prerequisite retains its existing behavior; no new status or phase inference.

### Discovery state and resource bounds

Use one private OnUpdate frame, inactive at startup and after termination. Accept two decimal positive integers <= 2147483647, first <= last, and at most 100000 IDs per run. These are safety limits, not claims about the largest Blizzard ID. Reject missing/extra tokens, fractional values, signs, exponent notation, reversed/oversized ranges before touching the prior report or API.

Probe at most 20 IDs per update and at most one batch per accumulated 0.1 seconds (no catch-up loops). For a missing title, attempt GetQuestObjectives to warm the cache; retain the ID for one retry after a probe-free ten-second interval following pass one. API exceptions are distinct errors; missing required functions prevent startup. Cancel is valid during both passes and warm-up; duplicate discovery starts are rejected. Keep audit behavior unchanged rather than building a shared scheduler; document that concurrent audit/overlay requests can warm the same client cache and should be avoided for reproducible comparisons.

### Report contract

Atomically publish optional EveryQuestDBPC.char.questApiDiscovery only at completion, formatVersion 1, firstID, lastID, startedAt, completedAt, addonVersion, clientVersion, clientBuild, interface, locale, total, found, missing, errors, titles keyed by numeric ID, and ordered probeErrors with bounded one-line reasons. Counts partition the inclusive range. Missing IDs are reconstructible from the range minus title/error IDs; do not persist a large redundant list. Preserve duplicate titles under separate IDs. Retain only the latest complete range (no merge/resume). Cancel, failed preflight and reload preserve the previous complete report. Clear removes only discovery's field and is refused during a run. Existing schema version and audit/history roots are untouched; older compatible versions ignore the optional field.

The report is the ID/title index for external exact-name comparison in the same locale. No automatic matching UI or rewrite is added. A missing API title and a successful title response establish neither existence nor obtainability conclusively.

### Tab completion

Install one chained wrapper at ChatEdit_CustomTabPressed only if that extension exists. Do not overwrite OnTabPressed, secure parsing, mixins or slash hash tables; a post-hook cannot return the handled flag and is unsuitable. For unhandled text return the previous callback's results, leaving name completion intact. No fallback global patch if the extension is absent: warn once and keep commands usable.

Complete only ASCII /everyquest tokens case-insensitively, with cursor at end; completion may clear highlighted selection; other slash roots, chat and mid-line edits delegate untouched. Candidates: root api/debug/help; under api audit/discover/overlay; under audit/discover status/cancel/clear. Unique prefixes replace the last token and append a space. Ambiguous prefixes print choices in chat and leave input unchanged. Numeric discover arguments are never invented: Tab at discover or in its numeric range prints the format hint and preserves numbers. No command executes or sends chat from completion. No popup or global key binding.

## Risks / Trade-offs

- Cold caches can still yield missing titles: retain metadata, bound retries, rerun deliberately; never claim full enumeration.
- Large ranges consume time/memory: explicit 100000-ID cap, throttling, one complete report and cancellation.
- Addon chat wrappers can conflict: chain the previous extension, scope handling narrowly, require live name-completion and chat-addon checks.
- Existing schema resets or unrelated errors are not discovery success: test persistence through actual Core initialization and separately verify flush in game.
- Developer command renaming breaks old macros intentionally; show new commands in CONTRIBUTING. No README/changelog promotion per user decision.

## Migration Plan

Import the overlay dependency without altering its original worktree; implement grouped commands, discovery and completion with tests; reconcile active specs. Run full gate and OpenSpec validation. Install only when authorized; test with script errors enabled in Anniversary. Rollback removes the new modules/routes; optional discovery data can remain ignored or be cleared beforehand. Keep live evidence pending until exercised; do not archive based solely on unit tests.
