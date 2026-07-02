# Milestones — Tasklite (eval fixture)

## Milestone 1 — Add + list [DONE]
**Goal:** capture and display tasks.
Delivered: `task add <title>` (validated — empty title is a friendly error, exit 1) and
`task list` (`[ ]`/`[x]` rendering). This is the baseline state all eval diffs apply to.

## Milestone 2 — Complete + filter [CURRENT]
**Goal:** mark tasks done and filter the list.
**Deliverables:** `task done <id>`; `task list --status open|done`.
**Acceptance Criteria (testable, observable):**
- [ ] M2-01 — `task done <id>` marks the task complete; a subsequent `task list` shows it as `[x]`
- [ ] M2-02 — `task list --status open|done` shows only tasks with that status
- [ ] M2-03 — `task done` with a non-existent or non-numeric id prints a friendly error to stderr and exits 1
**Verification:** pytest + captured CLI stdout/exit codes to `verification-shots/M2/`
(see the fixture VERIFICATION.md §3).
**Autonomy:** auto-verifiable
**DO-NOT-BUILD:** a delete command; due dates; priorities; any schema change beyond the
documented data model.
