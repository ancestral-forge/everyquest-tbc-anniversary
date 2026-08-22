## Context

GitLab admits only version-tag, scheduled, and web pipelines. Their jobs are
currently automatic once a matching pipeline exists. See `proposal.md` for the
reason to change that contract and the release-delivery delta for observable
behavior.

## Goals / Non-Goals

**Goals:**

- Preserve the existing pipeline admission rules and job dependency graph.
- Make runner use an explicit maintainer decision at the job level.
- Keep the manual behavior visible beside each condition that creates a job.

**Non-Goals:**

- Do not change GitHub automation, runner images, scripts, stages, or secrets.
- Do not add a second confirmation after GitLab's normal manual-job action.

## Decisions

### Declare manual behavior in each matching rule

Add `when: manual` and explicit `allow_failure: false` to every rule that can
create a job. Rule-local settings keep the condition and resulting behavior
together and make each job blocking, so later stages cannot bypass unfinished
release validation.

Alternative considered: job-level `when: manual`. Rule-local behavior is less
ambiguous when jobs already use `rules` and preserves the blocking default
explicitly.

### Keep pipeline creation automatic

Retain `workflow.rules`. GitLab can therefore show the relevant actions for a
tag, schedule, or web pipeline without allocating a runner until Play is used.

Alternative considered: remove scheduled pipelines entirely. That would remove
the prepared fallback operation instead of making its execution opt-in.

## Risks / Trade-offs

- [Release and backup pipelines remain blocked until acted on] -> This is the
  intended visible signal that no runner-consuming operation has been approved.
- [Maintainers must start validation before publication] -> Keep the existing
  `needs` graph so the required order is visible and enforced.

## Migration Plan

Apply the rule-local manual settings and archive the specification delta. A
rollback removes those settings and the added living requirement; no addon,
data, package, or client migration is involved.
