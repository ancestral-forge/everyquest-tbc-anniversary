# Addon Runtime Specification

## Purpose

Capture the durable runtime boundaries that every EveryQuest change must
preserve unless a reviewed OpenSpec change explicitly revises them.

## Requirements

### Requirement: TBC Anniversary runtime target
The addon SHALL target WoW TBC Anniversary Interface `20506` and Lua 5.1.

#### Scenario: Adding or changing runtime code
- **WHEN** Lua, XML, or TOC files change
- **THEN** the result remains valid for Interface 20506 and Lua 5.1
- **AND** older-client compatibility branches are not added without an explicit scope change

### Requirement: Blizzard-owned quest UI
EveryQuest SHALL observe and record quest state without replacing Blizzard-owned
secure reward or quest-completion UI handlers.

#### Scenario: Recording quest completion
- **WHEN** the client emits quest lifecycle events
- **THEN** EveryQuest updates its history from supported events and APIs
- **AND** Blizzard remains responsible for reward choice and quest completion controls

### Requirement: SavedVariables compatibility
Changes SHALL preserve existing per-account and per-character quest history
unless the change specifies and tests a versioned migration.

#### Scenario: Stored schema changes
- **WHEN** a change alters the shape or meaning of `EveryQuestDB` or `EveryQuestDBPC`
- **THEN** the OpenSpec design defines compatibility, migration, idempotence, and rollback behavior
- **AND** focused regression coverage protects existing history fields

### Requirement: Attribution and provenance
The maintained addon SHALL preserve GPL-2.0-only licensing, original EveryQuest
attribution, and reviewable provenance for imported quest data.

#### Scenario: Adding code or quest data
- **WHEN** a change introduces third-party code, assets, or generated quest records
- **THEN** its source and compatible license are documented before distribution
