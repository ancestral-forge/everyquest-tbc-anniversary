## Purpose

Give maintainers a bounded index of quest titles returned by the Anniversary API for IDs outside the shipped database, without treating observations as quest truth.

## ADDED Requirements

### Requirement: Explicit bounded range
Discovery SHALL run only through `/everyquest api discover <first> <last>`, accepting decimal positive integers <= 2147483647 and an inclusive ascending range of at most 100000 IDs. Invalid or extra arguments SHALL cause no probing or report mutation.

#### Scenario: Invalid range
- **WHEN** arguments are absent, fractional, nondecimal, reversed or oversized
- **THEN** usage and the limit are reported and no run starts

#### Scenario: Valid range
- **WHEN** a valid range is submitted
- **THEN** every ID in that range is considered in ascending order, independent of EveryQuest data modules

### Requirement: Bounded conservative observations
Discovery SHALL throttle work to no more than 20 IDs per 0.1-second update interval, warm missing titles, wait at least ten probe-free seconds after pass one, and retry only missing candidates once. Empty results and API errors SHALL remain distinct; absent required APIs SHALL prevent startup.

#### Scenario: Cold cache
- **WHEN** a first probe is empty and the retry returns a title
- **THEN** the ID is recorded as found, not missing

#### Scenario: Persistent missing data or exception
- **WHEN** the retry is empty or an API call raises an exception
- **THEN** the ID is classified as missing or error respectively, never as a removed quest

### Requirement: Complete report and lifecycle
Discovery SHALL offer status/cancel/clear, reject concurrent discovery runs and refuse clear during a run. Only completion SHALL replace the optional per-character questApiDiscovery report with version, range, timestamps, addon/client/build/interface/locale metadata, counts, ID/title pairs and ordered error IDs/reasons. Counts SHALL partition the range; identical titles SHALL retain every ID. Cancellation, failure and reload SHALL preserve the previous complete report; idle clear SHALL remove only discovery data.

#### Scenario: Cancel during warm-up
- **WHEN** cancellation occurs before retry
- **THEN** all pending work stops and the preceding complete report remains unchanged

#### Scenario: Duplicate names
- **WHEN** two IDs return the same title
- **THEN** both ID/title pairs survive in the complete report

#### Scenario: Reload and rollback
- **WHEN** saved data is flushed and reloaded, or read by an older compatible addon
- **THEN** history and the separate audit report remain readable without a schema migration, and discovery does not start automatically

### Requirement: Evidence-only compatible runtime
The feature SHALL preserve Lua 5.1, Interface 20506, GPL-2.0-only attribution, quest data, history and Blizzard quest UI ownership. Documentation SHALL distinguish a discovered title index from a full database and warn that name matches need locale-aware independent verification. Static checks SHALL NOT be reported as live-client proof.

#### Scenario: Replacement candidate
- **WHEN** another ID has the same title as an EveryQuest record
- **THEN** the addon does not change either quest ID, phase, status or saved history
