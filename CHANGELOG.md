# Changelog — Project Forge

All notable changes to the Forge methodology are recorded here. The canonical
version lives in `PROJECT_FORGE.md` (the `**Forge vX.Y**` line); this file tracks
its history. Format loosely follows Keep a Changelog; dates are ISO 8601.

## 1.5 — 2026-06-23

### Added
- **Memory map — the durable-knowledge layer** (`PROJECT_FORGE.md`). Replaces the old
  "Reference-doc loading discipline" with an indexed, linked-node memory model: a `KNOWLEDGE.md`
  index hub lists every knowledge node, and the agent loads the *map* and traverses to the 1–3
  nodes a task needs instead of bulk-reading the corpus — with maintenance rules (no orphans, no
  stale edges) so it doesn't rot. Tier-scaled (Tier 2+). `HANDOFF.md` stays the separate
  session-state layer; `DECISIONS.md` becomes a node on the map. Added to the Documents and
  Tiers tables.
- **Milestone 0 — project setup** (`PROJECT_FORGE.md`). A one-time bootstrap phase before the
  first feature: a version-controlled repo with a secret-aware `.gitignore`, a runnable skeleton,
  the toolchain proven, the Forge harness (mid-build hook + `/forge-verify` + snapshot hook), and
  a baseline commit. Added to the Workflow rhythm; covers machine-readiness for first-time builders.
- **Shipping — getting it live** (`PROJECT_FORGE.md`). A delivery discipline: deploy early to a
  real URL, Claude recommends hosting and guides setup while the human owns anything
  billable/irreversible (tripwires), secrets in the host's config, environments kept separate.
  Provider-agnostic, mirroring the model-agnostic rule.
- **Model right-sizing guidance** (`PROJECT_FORGE.md`). The Model Choice section now says to
  match the model to the task's *difficulty*, not just its role — a mid-tier model for mechanical
  execution, the frontier model reserved for architecture, tricky logic, debugging, and
  security-sensitive work — with caveats against under-powering or over-switching. New Operating
  Tip: watch for over-powering the task.

### Changed
- **Forge broadened from "system designer" to anyone** (`PROJECT_FORGE.md`). The audience framing
  now spans non-developers to experienced engineers. The planning persona gains experience
  calibration and a decision-ownership rule (the less the user knows, the more Claude proposes
  with a recommendation; but the goal, billable/irreversible calls, and "is this what I wanted?"
  stay the user's), and the opening question round now establishes experience level, environment,
  and whether it ships to the internet.
- **`docs/` folder convention** (`PROJECT_FORGE.md`). Generated reference docs now default to a
  `docs/` folder instead of the project root; root keeps only the always-loaded control files
  (`CLAUDE.md`, `HANDOFF.md`, and the auto snapshot). The Documents table *Lives in* column and
  the planning persona's output behaviour were updated to match — write to `docs/` in Claude
  Code, suggest the folder and label target paths in Claude.ai.
- **Consistency pass** (`PROJECT_FORGE.md`). Audience-broadening carried into the Security
  principle; "visual check" → "observable-outcome check (Check 8)"; the two testing layers
  (mid-build / gate) no longer reuse "Tier 1/Tier 2" labels that collided with project tiers; the
  embedded VERIFICATION template marked as the short form; MILESTONES template linked to
  Milestone 0; "QA checklist" tied to Build Rhythm step 4.

## 1.4 — 2026-06-23

### Added
- **Security core principle** (`PROJECT_FORGE.md`). Security is now a first-class Core
  Principle, placed first — above Leanness. It makes the planning partner responsible for
  raising security in plain language *before any code*, states secure-by-default rules that
  hold regardless of language, framework, or platform, and points to the existing enforcement
  (never-lean-able floor, Verifier Check 5, Autonomous Mode tripwire).
- **Autonomous-mode verifiability triage** (`FORGE_AUTONOMOUS_MODE.md` §2a; MILESTONES.md
  template in `PROJECT_FORGE.md`). Each milestone is now tagged `auto-verifiable` or
  `needs-human-check` during planning. The run loop stops for human review on a
  `needs-human-check` milestone *even on a Verifier PASS* — distinct from a tripwire, which
  guards irreversible actions; this guards judgment a machine can't sign off on. Milestones
  gain `Verification:` (how the outcome is proven on this platform) and `Autonomy:` fields.

### Changed
- Broadened the `PROJECT_FORGE.md` intro — the anchor doc is now dropped into "a Claude.ai
  Project or Claude Code" (was "a Claude.ai Project"), reflecting that Forge is harness-agnostic.
- **Verification generalised beyond the browser** (`VERIFICATION.md` Check 8, §3, Check 4;
  templates in `PROJECT_FORGE.md`). The old "Visual verification (Playwright screenshots)"
  check is now "Observable-outcome verification," covering web/desktop UI screenshots, CLI
  stdout + exit code, and generated-file artifacts — and now applies to *every* milestone, not
  only those with a UI. Playwright/browser is kept as the worked example, not the assumption.

## 1.3 — 2026-06-23

Baseline entry: the methodology as it stands at the introduction of `CLAUDE.md`
and this changelog. The methodology comprises three docs:

- **`PROJECT_FORGE.md`** — the anchor: principles, planning/execution workflow,
  project tiers, document templates, the Verifier gate, and core principles
  (leanness, model-agnostic execution).
- **`VERIFICATION.md`** — the dual-reader gate spec: the eight checks, staging
  checkpoints, output format, and the debt ledger.
- **`FORGE_AUTONOMOUS_MODE.md`** — the autonomous profile: the run loop, stop
  rules, tripwires, and the retrofit/adoption procedure.
