# Changelog — Project Forge

All notable changes to the Forge methodology are recorded here. The canonical
version lives in `PROJECT_FORGE.md` (the `**Forge vX.Y**` line); this file tracks
its history. Format loosely follows Keep a Changelog; dates are ISO 8601.

## 1.10 — 2026-07-02

### Added
- **Tamper-resistant acceptance ledger** (`ACCEPTANCE.json`, Tier 2+): acceptance criteria
  mirrored into a JSON ledger with a flip-only contract — the executor may change only
  `passes`/`evidence`; Verifier Check 1 verifies every flip against its cited evidence and
  treats any other edit as tampering (FAIL). Added to the Documents and Tiers tables, the
  CLAUDE.md template rules, and the Verifier input set. (Parked-research item B1.)

### Changed
- **Verifier over-flagging counterweight** (`VERIFICATION.md` §0; `PROJECT_FORGE.md`
  Verifier section): the adversarial stance now carries an explicit bound — flag only what
  affects correctness, a stated criterion, or the Check 5 floor; everything else is a note,
  never grounds to withhold PASS. (Item B4.)
- `PARKED_RESEARCH.md` gains a triage-status block: A1/A2 adopted in v1.8, C1/C2 in v1.9,
  B1/B4 in v1.10; B2 (Verifier eval set) named the next candidate.
- Canonical version bumped to **1.10**.

## 1.9 — 2026-06-24

### Added
- **Dev-ops automation section** (`PROJECT_FORGE.md`, after Shipping): a portable contract —
  deterministic checks belong in automation (cheap, no model); agentic verification stays in
  the loop, not the pipeline; platform-native automation is switched on before anything is
  built; the billable/irreversible line stays human-owned (the Shipping tripwire); every
  model-invoking unattended run is capped and watched; and a misbound automated run is
  unguarded (the canary rides along). Carries a voicing rule mirroring the Security
  principle: dev-ops decisions are raised in plain language and proposed with a
  recommendation — the builder should never have to know to ask.
- **Milestone 0 automation step** (`PROJECT_FORGE.md`): the deterministic battery wired to
  run on push + native dependency scanning, switched on once at setup (tier-scaled).
- **Claude Code + GitHub dev-ops appendix** (`PROJECT_FORGE.md`): a quarantined
  implementation of the contract — the deterministic/agentic split; `claude -p` as the
  headless primitive (VS Code terminal, not the desktop GUI); subscription cost control
  (`--max-turns` + `total_cost_usd`; `--max-budget-usd` flagged API-key-path / trailing-cap /
  unconfirmed-on-subscription); the `--bare` collision (skips CLAUDE.md + hooks → deny-list
  and canary inert unless `--settings` re-passed); the jq local-vs-runner distinction;
  CI guard-presence (canary + `system/init` `plugin_errors`); `dontAsk` for locked-down CI;
  the opt-in GitHub Action; and a studied-and-rejected list (agentic-Verifier-in-CI,
  auto-deploy/merge, the four-handler hook zoo). Documented against Claude Code 2.1.x;
  confirm behaviourally.

### Changed
- Canonical version bumped to **1.9** in `PROJECT_FORGE.md`; the `CLAUDE.md` version mention
  updated in the same change.

## 1.8 — 2026-06-24

### Added
- **Claude Code enforcement appendix** (`FORGE_AUTONOMOUS_MODE.md`): a harness-specific
  implementation of the tripwire contract — `permissions.deny` as the primary control (blocks
  even under `bypassPermissions`), `ask` as a project-localised pattern, a `PreToolUse` hook as
  optional secondary (fails open on error/exit-1, jq-free, structured-match), and a mandatory
  startup canary. Verified behaviourally on Claude Code 2.1.187 (Win + Git Bash).
- **Startup canary as a mandatory run-start guard-presence check** (§2) + matching STOP RULES
  line (§3): config binds at session start, so a mis-bound session leaves guardrails
  present-but-inert ("looks armed but isn't"); the agent can't introspect its own config, so
  loading is confirmed behaviourally.

### Changed
- §4 gains the **enforcement contract** (enforce where the harness can; confirm behaviourally),
  keeping the prose tripwire list as the portable spec and pointing to the appendix.
- `VERIFICATION.md` Check 4 names the deny/ask baseline as protected security state; Check 6
  confirms the autonomous run's guard-presence check was performed and recorded.

## 1.7 — 2026-06-23

### Fixed
- **Verifier input contract reconciled with the v1.5 memory map**
  (`VERIFICATION.md` §0, `PROJECT_FORGE.md`). v1.5 made `ARCHITECTURE.md` a node in a
  linked, splittable web, but the Verifier's input contract still treated architecture as
  one flat file — so on a decomposed build the Verifier would receive the index, not the
  territory ("checking against fiction"). Encoded the rule that the map's load-by-traversal
  economy is **builder-side only**: at the gate the Verifier always receives the full
  current architecture, assembled deterministically, never a traversed selection. Added a
  "Why the Verifier never traverses" subsection to VERIFICATION.md §0, matched the embedded
  short-form template, and added a builder-side-only boundary note to the memory-map section.

## 1.6 — 2026-06-23

### Fixed
- **Cumulative debt budget is now actually enforced** (`FORGE_AUTONOMOUS_MODE.md` §2, §3).
  VERIFICATION.md §4 defined a loop-level cumulative debt budget and pointed at
  FORGE_AUTONOMOUS_MODE.md for enforcement, but neither the run loop (§2) nor the STOP
  RULES (§3) implemented it — a load-bearing rule that did nothing. Added a cumulative
  debt gate as the first step of the run loop (fires before every milestone, including on
  auto-proceed) and a matching STOP RULES line. The Verifier sees one diff and structurally
  cannot judge accumulated debt; this check lives at the orchestration level, by design.

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
