## Purpose

Provide a consistent maintainer command namespace and local Tab completion without interfering with normal chat, player name completion or command execution.

## ADDED Requirements

### Requirement: Grouped API commands
EveryQuest SHALL route `api audit`, `api discover` and `api overlay`, with status/cancel/clear for both scanners. Audit semantics and overlay phase/status composition SHALL remain unchanged. Old `audit-api` and `apioverlay` spellings SHALL not execute diagnostics; ordinary toggle/debug/help SHALL remain functional.

#### Scenario: Audit subcommand
- **WHEN** `/everyquest api audit cancel` is entered
- **THEN** the audit cancels without clearing its previous complete report

#### Scenario: Overlay toggle
- **WHEN** `/everyquest api overlay` is entered twice
- **THEN** the session-only marker is enabled and then disabled, retaining reset-on-reload behavior

### Requirement: Scoped Tab suggestions
Tab completion SHALL act only on `/everyquest` tokens at the end of input; completion MAY clear highlighted selection. A unique prefix SHALL expand with a trailing space; ambiguous input SHALL show choices without replacing text. Suggestions SHALL include api/debug/help at root, audit/discover/overlay under api, and status/cancel/clear for scanners. Numeric discovery ranges SHALL receive a usage hint without fabricated numbers. Completion SHALL never send chat or execute commands.

#### Scenario: Unique action
- **WHEN** the user presses Tab after `/everyquest api au`
- **THEN** input becomes `/everyquest api audit ` without starting a scan

#### Scenario: Ambiguous action
- **WHEN** Tab is pressed after `/everyquest api `
- **THEN** audit, discover and overlay are shown as choices and input is unchanged

#### Scenario: Highlighted text with cursor at end
- **WHEN** Tab expands a unique command prefix while text is highlighted and the cursor is at the end
- **THEN** the command is completed and the highlight may be cleared without executing the command

#### Scenario: Numeric range
- **WHEN** Tab is pressed after `/everyquest api discover 100 `
- **THEN** the range syntax is shown and the supplied number is preserved

### Requirement: Preserve Blizzard and other addon chat behavior
Unrelated input and mid-line edits SHALL retain the previous completion behavior. Integration SHALL use the designated addon extension, not replace secure chat handlers; an absent extension SHALL leave commands usable and issue a single warning rather than install an unsafe fallback.

#### Scenario: Player names
- **WHEN** Tab is used in normal chat or a whisper command
- **THEN** EveryQuest does not modify the text or suppress the prior handler

#### Scenario: Unsupported completion extension
- **WHEN** the client lacks the addon completion extension
- **THEN** diagnostic commands still work and only completion is unavailable

### Requirement: Maintainer documentation
CONTRIBUTING SHALL document renamed commands, completion and report limits without README or regular player-options promotion. Prior active diagnostic specifications SHALL be reconciled with the new spelling while retaining dated evidence. Developer-only changelog omission SHALL follow the explicit user decision.

#### Scenario: Maintainer follows documentation
- **WHEN** documented examples are executed
- **THEN** they use the grouped namespace and distinguish audit, discovery and overlay
